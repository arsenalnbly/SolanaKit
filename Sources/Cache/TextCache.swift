//
//  TextCache.swift
//  SolanaKit
//
//  Created by arsenal on 22.09.25.
//

import Foundation
import SQLite3

// Bridge for SQLITE_TRANSIENT so Swift can use it
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

// MARK: - Public API

public enum EntryType: String {
    case account_details
    case transaction_details
    case transaction_history
}

public enum TextCacheEvictionPolicy {
    case none
    case lru
}

public enum TextCacheError: Error {
    case closed
    case notFound
    case invalidKey
    case ioFailure(message: String)
}

public struct TextCacheEntryInfo {
    public let key: String
    public let sizeBytes: Int
    public let createdAt: Date
    public let lastAccessedAt: Date
    public let expiresAt: Date?
}

/// A small text key/value cache persisted in SQLite with TTL + pruning.
public final class TextCacheStore {

    // MARK: Configuration
    public let name: String
    public let directory: URL
    public var capacityBytes: Int64
    public var defaultTTL: TimeInterval?
    public var evictionPolicy: TextCacheEvictionPolicy
    public private(set) var isClosed: Bool = false

    // MARK: Internals
    private let queue = DispatchQueue(label: "TextCacheStore.\(UUID().uuidString)")
    private var db: OpaquePointer?

    // MARK: Lifecycle

    /// - Parameters:
    ///   - name: logical cache name; db file will be `<name>.sqlite`
    ///   - directory: folder where the sqlite file will live
    ///   - capacityBytes: soft cap; enforced on `prune(obeyCapacity:true)` and on writes
    ///   - defaultTTL: default expiry for new values (nil = no expiry)
    ///   - evictionPolicy: when over capacity, how to evict (currently `.lru` or `.none`)
    public init(
        name: String,
        directory: URL,
        capacityBytes: Int64 = 50 * 1024 * 1024,
        defaultTTL: TimeInterval? = nil,
        evictionPolicy: TextCacheEvictionPolicy = .lru
    ) throws {
        self.name = name
        self.directory = directory
        self.capacityBytes = capacityBytes
        self.defaultTTL = defaultTTL
        self.evictionPolicy = evictionPolicy

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let dbURL = directory.appendingPathComponent("\(name).sqlite")

        try queue.sync {
            try openDB(at: dbURL)
            try configurePragmas()
            try createSchemaIfNeeded()
        }
    }

    deinit {
        try? close()
    }

    // MARK: - Public KV

    /// Set a UTF-8 text value with optional TTL (seconds). If `ttl` is nil, uses `defaultTTL`.
    public func set(_ value: Data, forKey key: String, ttl: TimeInterval? = nil, type : EntryType) throws {
        guard !key.isEmpty else { throw TextCacheError.invalidKey }
        try ensureOpen()

        try queue.sync {
            let now = Self.now()
            let expires = resolvedExpiry(from: ttl, now: now)

            // Upsert; preserve createdAt on update
            let sql = """
            INSERT INTO entries(key, value, size_bytes, created_at, last_accessed_at, expires_at, type)
            VALUES(?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(key) DO UPDATE SET
                value = excluded.value,
                size_bytes = excluded.size_bytes,
                last_accessed_at = excluded.last_accessed_at,
                expires_at = excluded.expires_at
            ;
            """
            let size = Int32(value.count)
            try withStatement(sql) { stmt in
                try bind_text(stmt, index: 1, text: key)
                try bind_blob(stmt, index: 2, data: value)
//                try bind(stmt, index: 2, text: value)
                sqlite3_bind_int(stmt, 3, size)
                sqlite3_bind_double(stmt, 4, now)
                sqlite3_bind_double(stmt, 5, now)
                if let exp = expires { sqlite3_bind_double(stmt, 6, exp) } else { sqlite3_bind_null(stmt, 6) }
                try bind_text(stmt, index: 7, text: type.rawValue)
                try stepDone(stmt)
            }

            // Enforce capacity if requested
            if evictionPolicy != .none, capacityBytes > 0 {
                try enforceCapacity()
            }
        }
    }
    /// Get a value; returns nil if missing or expired (expired entries are deleted on access).
    public func getByType(_ type: EntryType, limit: Int) throws -> [Data] {
        //        guard !type.isEmpty else { throw TextCacheError.invalidKey }
        try ensureOpen()
        
        return try queue.sync {
            // Fast path: check expired and delete if needed
            let now = Self.now()
            
            // read value and expiry
            let selectSQL = "SELECT key, value, expires_at, size_bytes FROM entries WHERE type = ? LIMIT ?;"
            
            var return_values: [Data] = []
            
            try withStatement(selectSQL) { stmt in
                try bind_text(stmt, index: 1, text: type.rawValue)
                sqlite3_bind_int(stmt, 2, Int32(limit))
                while sqlite3_step(stmt) == SQLITE_ROW {
                    guard let key = stringColumn(stmt, 0) else { continue }
                    let size = sqlite3_column_int(stmt, 3)
                    guard let value = blobColumn(stmt, 1, size) else { continue }
                    if sqlite3_column_type(stmt, 2) != SQLITE_NULL {
                        let exp = sqlite3_column_double(stmt, 2)
                        if (exp <= now) {
                            try remove(key)
                            continue
                        }
                    }
                    return_values.append(value)
                    // Touch last_accessed
                    let touchSQL = "UPDATE entries SET last_accessed_at = ? WHERE key = ?;"
                    try withStatement(touchSQL) { stmt in
                        sqlite3_bind_double(stmt, 1, now)
                        try bind_text(stmt, index: 2, text: key)
                        try stepDone(stmt)
                    }
                }
            }
            return return_values
        }
    }

    /// Get a value; returns nil if missing or expired (expired entries are deleted on access).
    public func get(_ key: String) throws -> Data? {
        guard !key.isEmpty else { throw TextCacheError.invalidKey }
        try ensureOpen()

        return try queue.sync {
            // Fast path: check expired and delete if needed
            let now = Self.now()

            // read value and expiry
            let selectSQL = "SELECT value, expires_at, size_bytes FROM entries WHERE key = ? LIMIT 1;"
            var value: Data?
            var expired = false

            try withStatement(selectSQL) { stmt in
                try bind_text(stmt, index: 1, text: key)
                if sqlite3_step(stmt) == SQLITE_ROW {
//                    value = stringColumn(stmt, 0)
                    let size = sqlite3_column_int(stmt, 2)
                    value = blobColumn(stmt, 0, size)
                    if sqlite3_column_type(stmt, 1) != SQLITE_NULL {
                        let exp = sqlite3_column_double(stmt, 1)
                        expired = (exp <= now)
                    }
                }
            }

            guard let val = value else { return Data() }

            if expired {
                try remove(key) // purge expired on read
                return Data()
            }

            // Touch last_accessed
            let touchSQL = "UPDATE entries SET last_accessed_at = ? WHERE key = ?;"
            try withStatement(touchSQL) { stmt in
                sqlite3_bind_double(stmt, 1, now)
                try bind_text(stmt, index: 2, text: key)
                try stepDone(stmt)
            }
            return val
        }
    }

    public func remove(_ key: String) throws {
        guard !key.isEmpty else { throw TextCacheError.invalidKey }
        try ensureOpen()
        try queue.sync {
            let sql = "DELETE FROM entries WHERE key = ?;"
            try withStatement(sql) { stmt in
                try bind_text(stmt, index: 1, text: key)
                try stepDone(stmt)
            }
        }
    }

    public func contains(_ key: String) -> Bool {
        guard !key.isEmpty else { return false }
        do {
            try ensureOpen()
            return try queue.sync {
                let now = Self.now()
                let sql = """
                SELECT 1 FROM entries
                WHERE key = ?
                  AND (expires_at IS NULL OR expires_at > ?)
                LIMIT 1;
                """
                var found = false
                try withStatement(sql) { stmt in
                    try bind_text(stmt, index: 1, text: key)
                    sqlite3_bind_double(stmt, 2, now)
                    found = (sqlite3_step(stmt) == SQLITE_ROW)
                }
                return found
            }
        } catch {
            return false
        }
    }

    // MARK: - Maintenance

    /// Prune expired and (optionally) enforce capacity.
    /// - Returns: (removedCount, removedBytes)
    @discardableResult
    public func prune(obeyCapacity: Bool = true) throws -> (Int, Int64) {
        try ensureOpen()
        return try queue.sync {
            var removedCount = 0
            var removedBytes: Int64 = 0

            // 1) Remove expired
            let now = Self.now()
            let sumSQL = "SELECT COUNT(*), COALESCE(SUM(size_bytes),0) FROM entries WHERE expires_at IS NOT NULL AND expires_at <= ?;"
            try withStatement(sumSQL) { stmt in
                sqlite3_bind_double(stmt, 1, now)
                if sqlite3_step(stmt) == SQLITE_ROW {
                    removedCount = Int(sqlite3_column_int(stmt, 0))
                    removedBytes = Int64(sqlite3_column_int64(stmt, 1))
                }
            }
            let deleteSQL = "DELETE FROM entries WHERE expires_at IS NOT NULL AND expires_at <= ?;"
            try withStatement(deleteSQL) { stmt in
                sqlite3_bind_double(stmt, 1, now)
                try stepDone(stmt)
            }

            // 2) Capacity enforcement (LRU)
            if obeyCapacity, evictionPolicy == .lru, capacityBytes > 0 {
                try enforceCapacity()
            }

            return (removedCount, removedBytes)
        }
    }

    public func removeAll() throws {
        try ensureOpen()
        try queue.sync {
            try exec("DELETE FROM entries;")
            // Optionally vacuum on big caches; VACUUM blocks, so keep it manual.
        }
    }

    /// Update expiry of a key. Pass `nil` to clear expiry (never expire).
    public func touch(_ key: String, ttl: TimeInterval? = nil) throws {
        guard !key.isEmpty else { throw TextCacheError.invalidKey }
        try ensureOpen()
        try queue.sync {
            let now = Self.now()
            let exp = resolvedExpiry(from: ttl, now: now)
            let sql = "UPDATE entries SET expires_at = ?, last_accessed_at = ? WHERE key = ?;"
            try withStatement(sql) { stmt in
                if let e = exp { sqlite3_bind_double(stmt, 1, e) } else { sqlite3_bind_null(stmt, 1) }
                sqlite3_bind_double(stmt, 2, now)
                try bind_text(stmt, index: 3, text: key)
                try stepDone(stmt)
            }
        }
    }

    // MARK: - Introspection

    public func entryInfo(forKey key: String) throws -> TextCacheEntryInfo? {
        guard !key.isEmpty else { throw TextCacheError.invalidKey }
        try ensureOpen()
        return try queue.sync {
            let sql = """
            SELECT key, size_bytes, created_at, last_accessed_at, expires_at
            FROM entries
            WHERE key = ?
            LIMIT 1;
            """
            var info: TextCacheEntryInfo?
            try withStatement(sql) { stmt in
                try bind_text(stmt, index: 1, text: key)
                if sqlite3_step(stmt) == SQLITE_ROW {
                    let k = stringColumn(stmt, 0) ?? key
                    let size = Int(sqlite3_column_int(stmt, 1))
                    let created = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 2))
                    let last = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 3))
                    let exp: Date? = (sqlite3_column_type(stmt, 4) == SQLITE_NULL) ? nil : Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4))
                    info = TextCacheEntryInfo(key: k, sizeBytes: size, createdAt: created, lastAccessedAt: last, expiresAt: exp)
                }
            }
            return info
        }
    }

    public func allKeys() -> [String] {
        (try? ensureOpen()) ?? ()
        return (try? queue.sync {
            let now = Self.now()
            let sql = """
            SELECT key FROM entries
            WHERE (expires_at IS NULL OR expires_at > ?)
            ORDER BY key ASC;
            """
            var keys: [String] = []
            try withStatement(sql) { stmt in
                sqlite3_bind_double(stmt, 1, now)
                while sqlite3_step(stmt) == SQLITE_ROW {
                    if let k = stringColumn(stmt, 0) { keys.append(k) }
                }
            }
            return keys
        }) ?? []
    }

    public func currentSizeBytes() -> Int64 {
        (try? ensureOpen()) ?? ()
        return (try? queue.sync {
            let now = Self.now()
            let sql = "SELECT COALESCE(SUM(size_bytes),0) FROM entries WHERE (expires_at IS NULL OR expires_at > ?);"
            var total: Int64 = 0
            try withStatement(sql) { stmt in
                sqlite3_bind_double(stmt, 1, now)
                if sqlite3_step(stmt) == SQLITE_ROW {
                    total = sqlite3_column_int64(stmt, 0)
                }
            }
            return total
        }) ?? 0
    }

    // MARK: - Close

    /// Drop the entries table completely and recreate it
    public func resetTable() throws {
        try ensureOpen()
        try queue.sync {
            // Drop the existing table
            try exec("DROP TABLE IF EXISTS entries;")
            // Recreate the table with fresh schema
            try createSchemaIfNeeded()
        }
    }

    public func close() throws {
        if isClosed { return }
        try queue.sync {
            if let db = db {
                let rc = sqlite3_close_v2(db)
                if rc != SQLITE_OK {
                    throw TextCacheError.ioFailure(message: "sqlite3_close_v2 failed: \(rc)")
                }
            }
            db = nil
            isClosed = true
        }
    }

    // MARK: - Private: DB setup

    private func openDB(at url: URL) throws {
        var handle: OpaquePointer?
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        let rc = sqlite3_open_v2(url.path, &handle, flags, nil)
        guard rc == SQLITE_OK, let handle else {
            throw TextCacheError.ioFailure(message: "Unable to open db: rc=\(rc)")
        }
        db = handle
    }

    private func configurePragmas() throws {
        // WAL improves concurrency; NORMAL sync is typically fine for cache.
        try exec("PRAGMA journal_mode=WAL;")
        try exec("PRAGMA synchronous=NORMAL;")
        try exec("PRAGMA temp_store=MEMORY;")
        try exec("PRAGMA mmap_size=134217728;") // 128MB (best-effort)
    }

    private func createSchemaIfNeeded() throws {
        let create = """
        CREATE TABLE IF NOT EXISTS entries(
            key TEXT PRIMARY KEY,
            value BLOB NOT NULL,
            size_bytes INTEGER NOT NULL,
            created_at REAL NOT NULL DEFAULT (strftime('%s','now')),
            last_accessed_at REAL NOT NULL,
            expires_at REAL NULL,
            type TEXT NOT NULL
        );
        """
        try exec(create)

        // Preserve created_at on upsert: add trigger if missing (idempotent-ish; ignore errors)
        let trigger = """
        CREATE TRIGGER IF NOT EXISTS entries_preserve_created_at
        AFTER UPDATE ON entries
        FOR EACH ROW
        WHEN NEW.created_at IS NOT OLD.created_at
        BEGIN
            UPDATE entries SET created_at = OLD.created_at WHERE key = NEW.key;
        END;
        """
        try? exec(trigger)

        try exec("CREATE INDEX IF NOT EXISTS idx_entries_expires_at ON entries(expires_at);")
        try exec("CREATE INDEX IF NOT EXISTS idx_entries_last_accessed ON entries(last_accessed_at);")
    }

    // MARK: - Private helpers

    private func enforceCapacity() throws {
        // Repeatedly delete oldest (LRU) until under capacity.
        var total = try liveSizeBytes()
        if total <= capacityBytes { return }

        // Delete in batches to avoid huge single statements
        let batchSQL = """
        SELECT key, size_bytes FROM entries
        WHERE (expires_at IS NULL OR expires_at > ?)
        ORDER BY last_accessed_at ASC
        LIMIT 256;
        """
        let now = Self.now()

        while total > capacityBytes {
            var toDelete: [(String, Int64)] = []
            try withStatement(batchSQL) { stmt in
                sqlite3_bind_double(stmt, 1, now)
                while sqlite3_step(stmt) == SQLITE_ROW {
                    let key = stringColumn(stmt, 0) ?? ""
                    let size = sqlite3_column_int64(stmt, 1)
                    toDelete.append((key, size))
                }
            }
            if toDelete.isEmpty { break } // nothing else to evict

            // Delete collected keys
            try exec("BEGIN IMMEDIATE;")
            defer { try? exec("COMMIT;") }

            for (k, sz) in toDelete {
                let del = "DELETE FROM entries WHERE key = ?;"
                try withStatement(del) { stmt in
                    try bind_text(stmt, index: 1, text: k)
                    try stepDone(stmt)
                }
                total -= sz
                if total <= capacityBytes { break }
            }
        }
    }

    private func liveSizeBytes() throws -> Int64 {
        let now = Self.now()
        var total: Int64 = 0
        try withStatement("SELECT COALESCE(SUM(size_bytes),0) FROM entries WHERE (expires_at IS NULL OR expires_at > ?);") { stmt in
            sqlite3_bind_double(stmt, 1, now)
            if sqlite3_step(stmt) == SQLITE_ROW {
                total = sqlite3_column_int64(stmt, 0)
            }
        }
        return total
    }

    private func resolvedExpiry(from ttl: TimeInterval?, now: TimeInterval) -> Double? {
        if let t = ttl ?? defaultTTL {
            return now + t
        }
        return nil
    }

    private func ensureOpen() throws {
        if isClosed || db == nil {
            throw TextCacheError.closed
        }
    }

    // MARK: - SQLite convenience

    private func exec(_ sql: String) throws {
        guard let db = db else { throw TextCacheError.closed }
        var err: UnsafeMutablePointer<Int8>?
        let rc = sqlite3_exec(db, sql, nil, nil, &err)
        if rc != SQLITE_OK {
            let msg = err.map { String(cString: $0) } ?? "unknown"
            sqlite3_free(err)
            throw TextCacheError.ioFailure(message: msg)
        }
    }

    private func withStatement<T>(_ sql: String, _ body: (OpaquePointer) throws -> T) throws -> T {
        guard let db = db else { throw TextCacheError.closed }
        var stmt: OpaquePointer?
        let rc = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        guard rc == SQLITE_OK, let stmt else {
            throw TextCacheError.ioFailure(message: "prepare failed rc=\(rc) for SQL: \(sql)")
        }
        defer { sqlite3_finalize(stmt) }
        return try body(stmt)
    }

    private func bind_text(_ stmt: OpaquePointer, index: Int32, text: String) throws {
        let rc = sqlite3_bind_text(stmt, index, text, -1, SQLITE_TRANSIENT)
        if rc != SQLITE_OK {
            throw TextCacheError.ioFailure(message: "bind text rc=\(rc)")
        }
    }
    
    private func bind_blob(_ stmt: OpaquePointer, index: Int32, data: Data) throws {
        try data.withUnsafeBytes { rawBuffer in
            // rawBuffer is UnsafeRawBufferPointer
            if let base = rawBuffer.baseAddress {
                let rc = sqlite3_bind_blob(
                    stmt,
                    2,                // parameter index
                    base,             // pointer to the bytes
                    Int32(data.count),// length
                    SQLITE_TRANSIENT  // copy the data
                )
                if rc != SQLITE_OK {
                    throw TextCacheError.ioFailure(message: "bind bytes rc=\(rc)")
                }
            }
        }
    }

    private func stepDone(_ stmt: OpaquePointer) throws {
        let rc = sqlite3_step(stmt)
        guard rc == SQLITE_DONE else {
            throw TextCacheError.ioFailure(message: "step rc=\(rc)")
        }
    }

    private func stringColumn(_ stmt: OpaquePointer, _ index: Int32) -> String? {
        guard let c = sqlite3_column_text(stmt, index) else { return nil }
        return String(cString: c)
    }
    
    private func blobColumn(_ stmt: OpaquePointer, _ index: Int32, _ size: Int32) -> Data? {
//        let size = Int(sqlite3_column_bytes(stmt, index))
        guard let ptr = sqlite3_column_blob(stmt, index) else { return nil }
        return Data(bytes: ptr, count: Int(size))
    }

    // MARK: - Time

    private static func now() -> Double { Date().timeIntervalSince1970 }
}

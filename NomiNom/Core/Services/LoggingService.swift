import Foundation
import OSLog
import Compression

enum LogLevel: String {
    case debug
    case info
    case warning
    case error
    case critical
}

struct LogContext: Codable {
    let category: String
    let file: String
    let function: String
    let line: Int
    let timestamp: Date
    let metadata: [String: String]?
    let correlationId: String?
    
    init(
        category: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        metadata: [String: String]? = nil,
        correlationId: String? = nil
    ) {
        self.category = category
        self.file = file
        self.function = function
        self.line = line
        self.timestamp = Date()
        self.metadata = metadata
        self.correlationId = correlationId
    }
}

protocol LoggingServiceProtocol {
    func log(
        level: LogLevel,
        message: String,
        context: LogContext
    )
}

final class LoggingService: LoggingServiceProtocol {
    static let shared = LoggingService()
    
    private let logger: Logger
    private let isDebug: Bool
    private let remoteLoggingEnabled: Bool
    private let sensitiveDataKeys: Set<String> = ["password", "token", "secret", "key", "authorization"]
    private let samplingRates: [LogLevel: Double] = [
        .debug: 0.1,    // Sample 10% of debug logs
        .info: 0.3,     // Sample 30% of info logs
        .warning: 0.5,  // Sample 50% of warning logs
        .error: 1.0,    // Sample 100% of error logs
        .critical: 1.0  // Sample 100% of critical logs
    ]
    
    private init() {
        #if DEBUG
        self.isDebug = true
        self.remoteLoggingEnabled = false
        #else
        self.isDebug = false
        self.remoteLoggingEnabled = true
        #endif
        
        self.logger = Logger(subsystem: "com.nominom.app", category: "default")
    }
    
    func log(
        level: LogLevel,
        message: String,
        context: LogContext
    ) {
        // Check if we should sample this log
        guard shouldSample(level) else { return }
        
        // Create structured log data
        var logData: [String: Any] = [
            "level": level.rawValue,
            "message": message,
            "category": context.category,
            "file": context.file,
            "function": context.function,
            "line": context.line,
            "timestamp": ISO8601DateFormatter().string(from: context.timestamp)
        ]
        
        if let correlationId = context.correlationId {
            logData["correlationId"] = correlationId
        }
        
        // Add metadata if present
        if let metadata = context.metadata {
            logData["metadata"] = sanitizeMetadata(metadata)
        }
        
        // Log to OSLog
        let osLogLevel: OSLogType
        switch level {
        case .debug:
            osLogLevel = .debug
        case .info:
            osLogLevel = .info
        case .warning:
            osLogLevel = .default
        case .error, .critical:
            osLogLevel = .error
        }
        
        logger.log(level: osLogLevel, "\(message)")
        
        // Log to console in debug mode
        if isDebug {
            print("[\(level.rawValue.uppercased())] [\(context.category)] \(message)")
            if let metadata = context.metadata {
                print("Metadata: \(metadata)")
            }
        }
        
        // Queue for remote logging
        if remoteLoggingEnabled {
            let logEntry = LogEntry(
                level: level,
                message: message,
                context: context,
                correlationId: context.correlationId
            )
            LogQueue.shared.enqueue(logEntry)
        }
    }
    
    private func shouldSample(_ level: LogLevel) -> Bool {
        guard let samplingRate = samplingRates[level] else { return true }
        return Double.random(in: 0...1) <= samplingRate
    }
    
    private func sanitizeMetadata(_ metadata: [String: String]) -> [String: String] {
        var sanitized = metadata
        
        for (key, value) in metadata {
            if sensitiveDataKeys.contains(key.lowercased()) {
                sanitized[key] = "***REDACTED***"
            }
        }
        
        return sanitized
    }
}

// MARK: - Convenience Methods
extension LoggingService {
    func debug(_ message: String, category: String, metadata: [String: String]? = nil, correlationId: String? = nil) {
        log(
            level: .debug,
            message: message,
            context: LogContext(category: category, metadata: metadata, correlationId: correlationId)
        )
    }
    
    func info(_ message: String, category: String, metadata: [String: String]? = nil, correlationId: String? = nil) {
        log(
            level: .info,
            message: message,
            context: LogContext(category: category, metadata: metadata, correlationId: correlationId)
        )
    }
    
    func warning(_ message: String, category: String, metadata: [String: String]? = nil, correlationId: String? = nil) {
        log(
            level: .warning,
            message: message,
            context: LogContext(category: category, metadata: metadata, correlationId: correlationId)
        )
    }
    
    func error(_ message: String, category: String, metadata: [String: String]? = nil, correlationId: String? = nil) {
        log(
            level: .error,
            message: message,
            context: LogContext(category: category, metadata: metadata, correlationId: correlationId)
        )
    }
    
    func critical(_ message: String, category: String, metadata: [String: String]? = nil, correlationId: String? = nil) {
        log(
            level: .critical,
            message: message,
            context: LogContext(category: category, metadata: metadata, correlationId: correlationId)
        )
    }
}

// MARK: - Log Queue
final class LogQueue {
    static let shared = LogQueue()
    
    private let queue = DispatchQueue(label: "com.nominom.logging.queue", qos: .utility)
    private let batchSize = 100
    private let flushInterval: TimeInterval = 30
    private var logs: [LogEntry] = []
    private var timer: Timer?
    
    private init() {
        setupTimer()
        loadCachedLogs()
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            self?.flush()
        }
    }
    
    private func loadCachedLogs() {
        // Load any cached logs from disk
        if let data = UserDefaults.standard.data(forKey: "cached_logs"),
           let cachedLogs = try? JSONDecoder().decode([LogEntry].self, from: data) {
            logs.append(contentsOf: cachedLogs)
        }
    }
    
    func enqueue(_ log: LogEntry) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.logs.append(log)
            
            if self.logs.count >= self.batchSize {
                self.flush()
            }
        }
    }
    
    private func flush() {
        queue.async { [weak self] in
            guard let self = self, !self.logs.isEmpty else { return }
            
            let batch = self.logs
            self.logs.removeAll()
            
            // Compress and send logs
            if let compressedData = self.compressLogs(batch) {
                self.sendToRemoteService(compressedData)
            }
            
            // Cache remaining logs
            self.cacheLogs()
        }
    }
    
    private func compressLogs(_ logs: [LogEntry]) -> Data? {
        guard let jsonData = try? JSONEncoder().encode(logs) else { return nil }
        
        let sourceSize = jsonData.count
        let destinationSize = sourceSize * 2
        let destination = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationSize)
        defer { destination.deallocate() }
        
        let algorithm = COMPRESSION_ZLIB
        let compressedSize = jsonData.withUnsafeBytes { rawBufferPointer in
            guard let baseAddress = rawBufferPointer.baseAddress else { return 0 }
            return compression_encode_buffer(
                destination,
                destinationSize,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                sourceSize,
                nil,
                algorithm
            )
        }
        
        guard compressedSize > 0 else { return nil }
        return Data(bytes: destination, count: compressedSize)
    }
    
    private func sendToRemoteService(_ data: Data) {
        // TODO: Implement actual remote service integration
        // This would typically be an async network call
    }
    
    private func cacheLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: "cached_logs")
        }
    }
}

// MARK: - Log Entry
struct LogEntry: Codable {
    let id: UUID
    let level: LogLevel
    let message: String
    let context: LogContext
    let timestamp: Date
    let correlationId: String?
    
    init(level: LogLevel, message: String, context: LogContext, correlationId: String? = nil) {
        self.id = UUID()
        self.level = level
        self.message = message
        self.context = context
        self.timestamp = Date()
        self.correlationId = correlationId
    }
} 
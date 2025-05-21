import Foundation
import OSLog

enum LogLevel: String {
    case debug
    case info
    case warning
    case error
    case critical
}

struct LogContext {
    let category: String
    let file: String
    let function: String
    let line: Int
    let timestamp: Date
    let metadata: [String: Any]?
    
    init(
        category: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        metadata: [String: Any]? = nil
    ) {
        self.category = category
        self.file = file
        self.function = function
        self.line = line
        self.timestamp = Date()
        self.metadata = metadata
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
        
        // Send to remote logging service in production
        if remoteLoggingEnabled {
            sendToRemoteLogging(logData)
        }
    }
    
    private func sanitizeMetadata(_ metadata: [String: Any]) -> [String: Any] {
        var sanitized = metadata
        
        for (key, value) in metadata {
            if sensitiveDataKeys.contains(key.lowercased()) {
                sanitized[key] = "***REDACTED***"
            } else if let dict = value as? [String: Any] {
                sanitized[key] = sanitizeMetadata(dict)
            }
        }
        
        return sanitized
    }
    
    private func sendToRemoteLogging(_ logData: [String: Any]) {
        // TODO: Implement remote logging service integration
        // This could be Firebase Crashlytics, Datadog, New Relic, etc.
    }
}

// MARK: - Convenience Methods
extension LoggingService {
    func debug(_ message: String, category: String, metadata: [String: Any]? = nil) {
        log(
            level: .debug,
            message: message,
            context: LogContext(category: category, metadata: metadata)
        )
    }
    
    func info(_ message: String, category: String, metadata: [String: Any]? = nil) {
        log(
            level: .info,
            message: message,
            context: LogContext(category: category, metadata: metadata)
        )
    }
    
    func warning(_ message: String, category: String, metadata: [String: Any]? = nil) {
        log(
            level: .warning,
            message: message,
            context: LogContext(category: category, metadata: metadata)
        )
    }
    
    func error(_ message: String, category: String, metadata: [String: Any]? = nil) {
        log(
            level: .error,
            message: message,
            context: LogContext(category: category, metadata: metadata)
        )
    }
    
    func critical(_ message: String, category: String, metadata: [String: Any]? = nil) {
        log(
            level: .critical,
            message: message,
            context: LogContext(category: category, metadata: metadata)
        )
    }
} 
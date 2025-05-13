import Foundation
import Combine

enum MessageType: String, Codable {
    case text = "TEXT"
    case image = "IMAGE"
    case location = "LOCATION"
    case system = "SYSTEM"
}

enum MessageStatus: String, Codable {
    case sent = "SENT"
    case delivered = "DELIVERED"
    case read = "READ"
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let type: MessageType
    let timestamp: Date
    var status: MessageStatus
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case receiverId
        case content
        case type
        case timestamp
        case status
    }
}

protocol ChatServiceProtocol {
    func connect(userId: String) async throws
    func disconnect()
    func sendMessage(_ message: ChatMessage) async throws
    func markMessageAsRead(_ messageId: String) async throws
    var messages: AnyPublisher<[ChatMessage], Never> { get }
    var connectionStatus: AnyPublisher<Bool, Never> { get }
}

final class ChatService: ChatServiceProtocol {
    static let shared = ChatService()
    
    private let baseURL = "ws://localhost:3000"
    private var webSocketTask: URLSessionWebSocketTask?
    private let messagesSubject = CurrentValueSubject<[ChatMessage], Never>([])
    private let connectionStatusSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables = Set<AnyCancellable>()
    
    var messages: AnyPublisher<[ChatMessage], Never> {
        messagesSubject.eraseToAnyPublisher()
    }
    
    var connectionStatus: AnyPublisher<Bool, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }
    
    private init() {
        setupMessageHandling()
    }
    
    private func setupMessageHandling() {
        // Handle incoming messages
        NotificationCenter.default.publisher(for: .newMessageReceived)
            .compactMap { notification -> ChatMessage? in
                notification.userInfo?["message"] as? ChatMessage
            }
            .sink { [weak self] message in
                self?.handleNewMessage(message)
            }
            .store(in: &cancellables)
    }
    
    func connect(userId: String) async throws {
        guard let url = URL(string: "\(baseURL)?userId=\(userId)") else {
            throw ChatError.invalidURL
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        
        webSocketTask?.resume()
        connectionStatusSubject.send(true)
        
        // Start receiving messages
        try await receiveMessages()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        connectionStatusSubject.send(false)
    }
    
    private func receiveMessages() async throws {
        guard let webSocketTask = webSocketTask else { return }
        
        do {
            let message = try await webSocketTask.receive()
            switch message {
            case .string(let text):
                if let data = text.data(using: .utf8),
                   let message = try? JSONDecoder().decode(ChatMessage.self, from: data) {
                    NotificationCenter.default.post(
                        name: .newMessageReceived,
                        object: nil,
                        userInfo: ["message": message]
                    )
                }
            case .data(let data):
                if let message = try? JSONDecoder().decode(ChatMessage.self, from: data) {
                    NotificationCenter.default.post(
                        name: .newMessageReceived,
                        object: nil,
                        userInfo: ["message": message]
                    )
                }
            @unknown default:
                break
            }
            
            // Continue receiving messages
            try await receiveMessages()
        } catch {
            connectionStatusSubject.send(false)
            throw ChatError.connectionError(error)
        }
    }
    
    func sendMessage(_ message: ChatMessage) async throws {
        guard let webSocketTask = webSocketTask else {
            throw ChatError.notConnected
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            let message = URLSessionWebSocketTask.Message.data(data)
            try await webSocketTask.send(message)
        } catch {
            throw ChatError.sendError(error)
        }
    }
    
    func markMessageAsRead(_ messageId: String) async throws {
        guard let webSocketTask = webSocketTask else {
            throw ChatError.notConnected
        }
        
        let readData: [String: Any] = [
            "type": "markAsRead",
            "messageId": messageId
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: readData)
            let message = URLSessionWebSocketTask.Message.data(data)
            try await webSocketTask.send(message)
        } catch {
            throw ChatError.sendError(error)
        }
    }
    
    private func handleNewMessage(_ message: ChatMessage) {
        var currentMessages = messagesSubject.value
        currentMessages.append(message)
        messagesSubject.send(currentMessages)
    }
}

enum ChatError: Error {
    case invalidURL
    case notConnected
    case connectionError(Error)
    case sendError(Error)
}

extension Notification.Name {
    static let newMessageReceived = Notification.Name("newMessageReceived")
} 

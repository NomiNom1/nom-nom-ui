//import Foundation
//import FirebaseDatabase
//import FirebaseAuth
//import Combine
//
//class ChatService: ObservableObject {
//    private var databaseRef: DatabaseReference
//    private var messagesRef: DatabaseReference
//    private var messageListener: DatabaseHandle?
//    private var presenceRef: DatabaseReference
//    private var typingRef: DatabaseReference
//    private var readReceiptRef: DatabaseReference
//    private var reactionsRef: DatabaseReference
//    private var cancellables = Set<AnyCancellable>()
//    
//    @Published var messages: [ChatMessage] = []
//    @Published var isConnected: Bool = false
//    @Published var typingUsers: [String: Bool] = [:]
//    @Published var onlineUsers: [String: Bool] = [:]
//    @Published var readReceipts: [String: [String: Date]] = [:] // messageId: [userId: timestamp]
//    @Published var messageReactions: [String: [String: [String]]] = [:] // messageId: [emoji: [userId]]
//    
//    init() {
//        self.databaseRef = Database.database().reference()
//        self.messagesRef = databaseRef.child("chats")
//        self.presenceRef = databaseRef.child("presence")
//        self.typingRef = databaseRef.child("typing")
//        self.readReceiptRef = databaseRef.child("readReceipts")
//        self.reactionsRef = databaseRef.child("reactions")
//        
//        setupPresenceSystem()
//    }
//    
//    private func setupPresenceSystem() {
//        // Set up presence system
//        let connectedRef = Database.database().reference(withPath: ".info/connected")
//        connectedRef.observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let isConnected = snapshot.value as? Bool,
//                  isConnected,
//                  let currentUserId = Auth.auth().currentUser?.uid else { return }
//            
//            // Set up presence
//            let userPresenceRef = self.presenceRef.child(currentUserId)
//            userPresenceRef.onDisconnectSetValue(["status": "offline", "lastSeen": ServerValue.timestamp()])
//            userPresenceRef.setValue(["status": "online", "lastSeen": ServerValue.timestamp()])
//        }
//    }
//    
//    func startListeningToChat(chatId: String) {
//        let chatRef = messagesRef.child(chatId)
//        
//        // Listen for messages
//        messageListener = chatRef.observe(.childAdded) { [weak self] snapshot in
//            guard let self = self,
//                  let messageData = snapshot.value as? [String: Any],
//                  let message = ChatMessage(dictionary: messageData) else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self.messages.append(message)
//            }
//        }
//        
//        // Listen for typing status
//        typingRef.child(chatId).observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let typingData = snapshot.value as? [String: Bool] else { return }
//            
//            DispatchQueue.main.async {
//                self.typingUsers = typingData
//            }
//        }
//        
//        // Listen for online status
//        presenceRef.observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let presenceData = snapshot.value as? [String: [String: Any]] else { return }
//            
//            DispatchQueue.main.async {
//                self.onlineUsers = presenceData.mapValues { data in
//                    return (data["status"] as? String) == "online"
//                }
//            }
//        }
//        
//        // Listen for read receipts
//        readReceiptRef.child(chatId).observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let receiptData = snapshot.value as? [String: [String: TimeInterval]] else { return }
//            
//            DispatchQueue.main.async {
//                self.readReceipts = receiptData.mapValues { userTimestamps in
//                    userTimestamps.mapValues { Date(timeIntervalSince1970: $0) }
//                }
//            }
//        }
//        
//        // Listen for reactions
//        reactionsRef.child(chatId).observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let reactionData = snapshot.value as? [String: [String: [String]]] else { return }
//            
//            DispatchQueue.main.async {
//                self.messageReactions = reactionData
//            }
//        }
//    }
//    
//    func sendMessage(_ message: ChatMessage, to chatId: String) {
//        let chatRef = messagesRef.child(chatId)
//        let messageRef = chatRef.childByAutoId()
//        
//        messageRef.setValue(message.toDictionary()) { [weak self] error, _ in
//            if let error = error {
//                print("Error sending message: \(error.localizedDescription)")
//            } else {
//                // Set initial read receipt for sender
//                self?.markMessageAsRead(messageId: messageRef.key ?? "", in: chatId)
//            }
//        }
//    }
//    
//    func setTypingStatus(isTyping: Bool, in chatId: String) {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        typingRef.child(chatId).child(currentUserId).setValue(isTyping)
//    }
//    
//    func markMessageAsRead(messageId: String, in chatId: String) {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        readReceiptRef.child(chatId)
//            .child(messageId)
//            .child(currentUserId)
//            .setValue(ServerValue.timestamp())
//    }
//    
//    func addReaction(_ emoji: String, to messageId: String, in chatId: String) {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        
//        let reactionRef = reactionsRef.child(chatId).child(messageId).child(emoji)
//        
//        // Get current reactions
//        reactionRef.observeSingleEvent(of: .value) { [weak self] snapshot in
//            guard let self = self else { return }
//            
//            var currentUsers = snapshot.value as? [String] ?? []
//            
//            // Toggle reaction
//            if currentUsers.contains(currentUserId) {
//                currentUsers.removeAll { $0 == currentUserId }
//            } else {
//                currentUsers.append(currentUserId)
//            }
//            
//            // Update or remove reaction
//            if currentUsers.isEmpty {
//                reactionRef.removeValue()
//            } else {
//                reactionRef.setValue(currentUsers)
//            }
//        }
//    }
//    
//    func stopListening() {
//        if let listener = messageListener {
//            messagesRef.removeObserver(withHandle: listener)
//        }
//        typingRef.removeAllObservers()
//        presenceRef.removeAllObservers()
//        readReceiptRef.removeAllObservers()
//        reactionsRef.removeAllObservers()
//    }
//}
//
//struct ChatMessage: Identifiable, Codable {
//    let id: String
//    let senderId: String
//    let senderName: String
//    let content: String
//    let timestamp: Date
//    let type: MessageType
//    
//    enum MessageType: String, Codable {
//        case text
//        case image
//        case location
//    }
//    
//    init(id: String = UUID().uuidString,
//         senderId: String,
//         senderName: String,
//         content: String,
//         timestamp: Date = Date(),
//         type: MessageType = .text) {
//        self.id = id
//        self.senderId = senderId
//        self.senderName = senderName
//        self.content = content
//        self.timestamp = timestamp
//        self.type = type
//    }
//    
//    init?(dictionary: [String: Any]) {
//        guard let id = dictionary["id"] as? String,
//              let senderId = dictionary["senderId"] as? String,
//              let senderName = dictionary["senderName"] as? String,
//              let content = dictionary["content"] as? String,
//              let timestamp = dictionary["timestamp"] as? TimeInterval,
//              let typeString = dictionary["type"] as? String,
//              let type = MessageType(rawValue: typeString) else {
//            return nil
//        }
//        
//        self.id = id
//        self.senderId = senderId
//        self.senderName = senderName
//        self.content = content
//        self.timestamp = Date(timeIntervalSince1970: timestamp)
//        self.type = type
//    }
//    
//    func toDictionary() -> [String: Any] {
//        return [
//            "id": id,
//            "senderId": senderId,
//            "senderName": senderName,
//            "content": content,
//            "timestamp": timestamp.timeIntervalSince1970,
//            "type": type.rawValue
//        ]
//    }
//} 

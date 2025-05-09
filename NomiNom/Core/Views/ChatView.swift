//import SwiftUI
//
//struct ChatView: View {
//    @StateObject private var chatService = ChatService()
//    @State private var messageText = ""
//    @State private var scrollProxy: ScrollViewProxy?
//    @State private var isTyping = false
//    private let typingDebounceTime: TimeInterval = 1.0
//    private var typingTimer: Timer?
//    
//    let chatId: String
//    let currentUserId: String
//    let otherUserId: String
//    
//    @State private var selectedMessageId: String?
//    @State private var showingEmojiPicker = false
//    @State private var reactionPosition: CGPoint = .zero
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header with online status
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(getUserName(for: otherUserId))
//                        .font(.headline)
//                    HStack {
//                        Circle()
//                            .fill(chatService.onlineUsers[otherUserId] == true ? Color.green : Color.gray)
//                            .frame(width: 8, height: 8)
//                        Text(chatService.onlineUsers[otherUserId] == true ? "Online" : "Offline")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//                Spacer()
//            }
//            .padding()
//            .background(Color(.systemBackground))
//            
//            Divider()
//            
//            // Messages
//            ScrollViewReader { proxy in
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(chatService.messages) { message in
//                            MessageBubble(
//                                message: message,
//                                isCurrentUser: message.senderId == currentUserId,
//                                readReceipts: chatService.readReceipts[message.id] ?? [:],
//                                reactions: chatService.reactions[message.id] ?? [:],
//                                onReaction: { emoji in
//                                    handleReaction(emoji, for: message.id)
//                                }
//                            )
//                            .id(message.id)
//                        }
//                    }
//                    .padding()
//                }
//                .onAppear {
//                    scrollProxy = proxy
//                }
//            }
//            
//            // Typing indicator
//            if !chatService.typingUsers.filter({ $0.key != currentUserId && $0.value }).isEmpty {
//                HStack {
//                    Text("Someone is typing...")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .padding(.leading)
//                    Spacer()
//                }
//                .padding(.vertical, 4)
//            }
//            
//            Divider()
//            
//            // Message input
//            HStack(spacing: 12) {
//                TextField("Type a message...", text: $messageText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .onChange(of: messageText) { _ in
//                        handleTyping()
//                    }
//                
//                Button(action: sendMessage) {
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor(.blue)
//                        .padding(.trailing)
//                }
//                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//            }
//            .padding(.vertical, 8)
//            .background(Color(.systemBackground))
//        }
//        .onAppear {
//            chatService.startListeningToChat(chatId: chatId)
//        }
//        .onDisappear {
//            chatService.stopListening()
//        }
//    }
//    
//    private func handleTyping() {
//        typingTimer?.invalidate()
//        
//        if !isTyping {
//            isTyping = true
//            chatService.setTypingStatus(isTyping: true, in: chatId)
//        }
//        
//        typingTimer = Timer.scheduledTimer(withTimeInterval: typingDebounceTime, repeats: false) { _ in
//            isTyping = false
//            chatService.setTypingStatus(isTyping: false, in: chatId)
//        }
//    }
//    
//    private func sendMessage() {
//        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//        
//        let message = ChatMessage(
//            senderId: currentUserId,
//            senderName: getUserName(for: currentUserId),
//            content: messageText
//        )
//        
//        chatService.sendMessage(message, to: chatId)
//        messageText = ""
//        chatService.setTypingStatus(isTyping: false, in: chatId)
//        
//        withAnimation {
//            scrollProxy?.scrollTo(chatService.messages.last?.id, anchor: .bottom)
//        }
//    }
//    
//    private func getUserName(for userId: String) -> String {
//        // This should be replaced with actual user name lookup from your user service
//        return userId == currentUserId ? "You" : "Other User"
//    }
//    
//    private func handleReaction(_ emoji: String, for messageId: String) {
//        chatService.addReaction(emoji, to: messageId)
//    }
//}
//
//struct MessageBubble: View {
//    let message: ChatMessage
//    let isCurrentUser: Bool
//    let readReceipts: [String: Date]
//    let reactions: [String: [String]]
//    let onReaction: (String) -> Void
//    
//    @State private var showingEmojiPicker = false
//    @State private var reactionPosition: CGPoint = .zero
//    
//    var body: some View {
//        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
//            if !isCurrentUser {
//                Text(message.senderName)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            
//            HStack(alignment: .bottom, spacing: 4) {
//                if isCurrentUser {
//                    ReadReceiptView(readReceipts: readReceipts)
//                }
//                
//                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
//                    Text(message.content)
//                        .padding(12)
//                        .background(isCurrentUser ? Color.blue : Color(.systemGray5))
//                        .foregroundColor(isCurrentUser ? .white : .primary)
//                        .cornerRadius(16)
//                        .onLongPressGesture(minimumDuration: 0.5) { location in
//                            reactionPosition = location
//                            showingEmojiPicker = true
//                        }
//                    
//                    // Reactions view
//                    if !reactions.isEmpty {
//                        HStack(spacing: 4) {
//                            ForEach(Array(reactions.keys.sorted()), id: \.self) { emoji in
//                                ReactionBubble(emoji: emoji, count: reactions[emoji]?.count ?? 0)
//                                    .onTapGesture {
//                                        onReaction(emoji)
//                                    }
//                            }
//                        }
//                        .padding(.horizontal, 4)
//                    }
//                }
//                
//                if !isCurrentUser {
//                    ReadReceiptView(readReceipts: readReceipts)
//                }
//            }
//            
//            Text(message.timestamp, style: .time)
//                .font(.caption2)
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
//        .overlay(
//            Group {
//                if showingEmojiPicker {
//                    EmojiPickerView(
//                        onEmojiSelected: { emoji in
//                            onReaction(emoji)
//                            showingEmojiPicker = false
//                        },
//                        onDismiss: {
//                            showingEmojiPicker = false
//                        }
//                    )
//                    .position(x: reactionPosition.x, y: reactionPosition.y - 100)
//                }
//            }
//        )
//    }
//}
//
//struct ReactionBubble: View {
//    let emoji: String
//    let count: Int
//    
//    var body: some View {
//        HStack(spacing: 2) {
//            Text(emoji)
//            if count > 1 {
//                Text("\(count)")
//                    .font(.caption2)
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(.horizontal, 6)
//        .padding(.vertical, 2)
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//    }
//}
//
//struct EmojiPickerView: View {
//    let onEmojiSelected: (String) -> Void
//    let onDismiss: () -> Void
//    
//    private let emojis = ["❤️", "👍", "😂", "😮", "😢", "🙏", "👏", "🔥", "🎉", "👎"]
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            HStack(spacing: 12) {
//                ForEach(emojis, id: \.self) { emoji in
//                    Button(action: {
//                        onEmojiSelected(emoji)
//                    }) {
//                        Text(emoji)
//                            .font(.title2)
//                    }
//                }
//            }
//            .padding()
//            .background(Color(.systemBackground))
//            .cornerRadius(20)
//            .shadow(radius: 5)
//        }
//        .onTapGesture {
//            onDismiss()
//        }
//    }
//}
//
//struct ReadReceiptView: View {
//    let readReceipts: [String: Date]
//    
//    var body: some View {
//        if !readReceipts.isEmpty {
//            Image(systemName: "checkmark.circle.fill")
//                .foregroundColor(.blue)
//                .font(.caption)
//        }
//    }
//}
//
//#Preview {
//    ChatView(chatId: "preview", currentUserId: "user1", otherUserId: "user2")
//} 

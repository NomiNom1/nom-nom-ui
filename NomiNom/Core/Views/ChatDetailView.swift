import SwiftUI
import Combine

struct ChatDetailView: View {
    let chat: Chat
    @StateObject private var viewModel: ChatDetailViewModel
    @EnvironmentObject private var userSessionManager: UserSessionManager
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    
    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chat: chat))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == userSessionManager.currentUser?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                }
            }
            
            // Message Input
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                            .padding(.trailing)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle(chat.participantName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let userId = userSessionManager.currentUser?.id {
                await viewModel.connect(userId: userId)
            }
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUserId = userSessionManager.currentUser?.id else { return }
        
        let message = ChatMessage(
            id: UUID().uuidString,
            senderId: currentUserId,
            receiverId: chat.participantId,
            content: messageText,
            type: .text,
            timestamp: Date(),
            status: .sent
        )
        
        Task {
            await viewModel.sendMessage(message)
            messageText = ""
            
            withAnimation {
                scrollProxy?.scrollTo(message.id, anchor: .bottom)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                HStack(spacing: 4) {
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if isCurrentUser {
                        Image(systemName: message.status == .read ? "checkmark.circle.fill" : "checkmark")
                            .font(.caption2)
                            .foregroundColor(message.status == .read ? .blue : .gray)
                    }
                }
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}

class ChatDetailViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    private let chat: Chat
    private let chatService: ChatServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(chat: Chat, chatService: ChatServiceProtocol = ChatService.shared) {
        self.chat = chat
        self.chatService = chatService
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        chatService.messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.updateMessages(messages)
            }
            .store(in: &cancellables)
    }
    
    func connect(userId: String) async {
        do {
            try await chatService.connect(userId: userId)
        } catch {
            print("Error connecting to chat service: \(error)")
        }
    }
    
    func disconnect() {
        chatService.disconnect()
    }
    
    func sendMessage(_ message: ChatMessage) async {
        do {
            try await chatService.sendMessage(message)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    private func updateMessages(_ allMessages: [ChatMessage]) {
        // Filter messages for this chat
        messages = allMessages.filter { message in
            (message.senderId == chat.participantId && message.receiverId == UserSessionManager.shared.currentUser?.id) ||
            (message.senderId == UserSessionManager.shared.currentUser?.id && message.receiverId == chat.participantId)
        }
        .sorted { $0.timestamp < $1.timestamp }
    }
}

#Preview {
    NavigationView {
        ChatDetailView(chat: Chat(
            id: "preview",
            participantId: "user2",
            participantName: "John Doe",
            lastMessage: nil
        ))
        .environmentObject(UserSessionManager.shared)
    }
} 
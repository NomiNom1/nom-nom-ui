import SwiftUI
import Combine

struct ChatListView: View {
    @StateObject private var coordinator = ChatCoordinator()
    @StateObject private var viewModel = ChatListViewModel()
    @EnvironmentObject private var userSessionManager: UserSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 0) {
                Text("Chat List View")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                List {
                    ForEach(viewModel.chats) { chat in
                        NavigationLink(destination: ChatDetailView(chat: chat)) {
                            ChatRowView(chat: chat)
                        }
                    }
                }
                .background(themeManager.currentTheme.background)
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.refreshChats()
                }
                .task {
                    if let userId = userSessionManager.currentUser?.id {
                        await viewModel.connect(userId: userId)
                    }
                }
                .onDisappear {
                    viewModel.disconnect()
                }
                .navigationBarHidden(true)
            }
            
            
            
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(chat.participantName.prefix(1))
                        .font(.title2)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.participantName)
                    .font(.headline)
                
                if let lastMessage = chat.lastMessage {
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // if let lastMessage = chat.lastMessage {
            //     Text(lastMessage.timestamp, style: .time)
            //         .font(.caption)
            //         .foregroundColor(.gray)
            // }
        }
        .padding(.vertical, 8)
    }
}

class ChatListViewModel: ObservableObject {
    @Published private(set) var chats: [Chat] = []
    private let chatService: ChatServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(chatService: ChatServiceProtocol = ChatService.shared) {
        self.chatService = chatService
        setupSubscriptions()
        
        // Add dummy data
        let dummyChats = [
            Chat(
                id: "1",
                participantId: "1",
                participantName: "John Smith",
                lastMessage: ChatMessage(
                    id: "1",
                    senderId: "1",
                    receiverId: "current_user",
                    content: "Hey, when will my order arrive?",
                    type: MessageType.text,
                    timestamp: Date().addingTimeInterval(-300).ISO8601Format(), // 5 minutes ago
                    status: MessageStatus.sent
                )
            ),
            Chat(
                id: "2",
                participantId: "2",
                participantName: "Sarah Johnson",
                lastMessage: ChatMessage(
                    id: "2",
                    senderId: "current_user",
                    receiverId: "2",
                    content: "Your order has been confirmed!",
                    type: MessageType.text,
                    timestamp: Date().addingTimeInterval(-3600).ISO8601Format(), // 1 hour ago
                    status: MessageStatus.sent
                )
            ),
            Chat(
                id: "3",
                participantId: "3",
                participantName: "Mike Wilson",
                lastMessage: ChatMessage(
                    id: "3",
                    senderId: "3",
                    receiverId: "current_user",
                    content: "Thank you for your order!",
                    type: MessageType.text,
                    timestamp: Date().addingTimeInterval(-86400).ISO8601Format(), // 1 day ago
                    status: MessageStatus.sent
                )
            )
        ]
        
        self.chats = dummyChats
    }
    
    private func setupSubscriptions() {
        chatService.messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.updateChats(with: messages)
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
    
    func refreshChats() async {
        // In a real app, this would fetch chats from your backend
        // For now, we'll just use the messages we receive through WebSocket
    }
    
    private func updateChats(with messages: [ChatMessage]) {
        // Group messages by chat (participant)
        let groupedMessages = Dictionary(grouping: messages) { message in
            message.senderId == UserSessionManager.shared.currentUser?.id ? message.receiverId : message.senderId
        }
        
        //        // Create chat objects
        //        chats = groupedMessages.map { participantId, messages in
        //            Chat(
        //                id: participantId,
        //                participantId: participantId,
        //                participantName: "User \(participantId.prefix(4))", // In a real app, fetch user details
        //                lastMessage: messages.sorted { $0.timestamp > $1.timestamp }.first
        //            )
        //        }
        //        .sorted { $0.lastMessage?.timestamp ?? Date() > $1.lastMessage?.timestamp ?? Date() }
    }
}

struct Chat: Identifiable {
    let id: String
    let participantId: String
    let participantName: String
    let lastMessage: ChatMessage?
}

#Preview {
    ChatListView()
        .environmentObject(UserSessionManager.shared)
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
}

import SwiftUI
import Combine

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @EnvironmentObject private var userSessionManager: UserSessionManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.chats) { chat in
                    NavigationLink(destination: ChatDetailView(chat: chat)) {
                        ChatRowView(chat: chat)
                    }
                }
            }
            .navigationTitle("Messages")
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
            
            if let lastMessage = chat.lastMessage {
                Text(lastMessage.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
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
        
        // Create chat objects
        chats = groupedMessages.map { participantId, messages in
            Chat(
                id: participantId,
                participantId: participantId,
                participantName: "User \(participantId.prefix(4))", // In a real app, fetch user details
                lastMessage: messages.sorted { $0.timestamp > $1.timestamp }.first
            )
        }
        .sorted { $0.lastMessage?.timestamp ?? Date() > $1.lastMessage?.timestamp ?? Date() }
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
} 
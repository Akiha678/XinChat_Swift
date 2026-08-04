import Foundation

/// 通讯业务的数据访问边界。
protocol ChatRepositoryProtocol {
    func fetchContacts(completion: @escaping (Result<[Contact], NetworkError>) -> Void)
    func fetchFriendCandidates(
        keyword: String,
        completion: @escaping (Result<[Contact], NetworkError>) -> Void
    )
    func sendFriendRequest(
        contactID: Int,
        completion: @escaping (Result<FriendRequestReceipt, NetworkError>) -> Void
    )
    func fetchIncomingFriendRequests(
        completion: @escaping (Result<[FriendRequest], NetworkError>) -> Void
    )
    func acceptFriendRequest(
        requestID: Int,
        completion: @escaping (Result<FriendRequest, NetworkError>) -> Void
    )
    func rejectFriendRequest(
        requestID: Int,
        completion: @escaping (Result<FriendRequest, NetworkError>) -> Void
    )
    func fetchConversations(completion: @escaping (Result<[Conversation], NetworkError>) -> Void)
    func createDirectConversation(
        friendID: Int,
        completion: @escaping (Result<Conversation, NetworkError>) -> Void
    )
    func fetchMessages(
        conversationID: Int,
        completion: @escaping (Result<[ChatMessage], NetworkError>) -> Void
    )
    func sendMessage(
        conversationID: Int,
        content: String,
        completion: @escaping (Result<ChatMessage, NetworkError>) -> Void
    )
    func markConversationRead(
        conversationID: Int,
        completion: @escaping (Result<ReadConversationReceipt, NetworkError>) -> Void
    )
}

/// 基于统一网络客户端的通讯数据仓库。
final class ChatRepository: ChatRepositoryProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func fetchContacts(completion: @escaping (Result<[Contact], NetworkError>) -> Void) {
        networkClient.request(ChatAPI.friends, responseType: [Contact].self, completion: completion)
    }

    func fetchFriendCandidates(
        keyword: String,
        completion: @escaping (Result<[Contact], NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.friendCandidates(keyword: keyword),
            responseType: [Contact].self,
            completion: completion
        )
    }

    func sendFriendRequest(
        contactID: Int,
        completion: @escaping (Result<FriendRequestReceipt, NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.sendFriendRequest(contactID: contactID),
            responseType: FriendRequestReceipt.self,
            completion: completion
        )
    }

    func fetchIncomingFriendRequests(
        completion: @escaping (Result<[FriendRequest], NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.incomingFriendRequests,
            responseType: [FriendRequest].self,
            completion: completion
        )
    }

    func acceptFriendRequest(
        requestID: Int,
        completion: @escaping (Result<FriendRequest, NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.acceptFriendRequest(requestID: requestID),
            responseType: FriendRequest.self,
            completion: completion
        )
    }

    func rejectFriendRequest(
        requestID: Int,
        completion: @escaping (Result<FriendRequest, NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.rejectFriendRequest(requestID: requestID),
            responseType: FriendRequest.self,
            completion: completion
        )
    }

    func fetchConversations(completion: @escaping (Result<[Conversation], NetworkError>) -> Void) {
        networkClient.request(ChatAPI.conversations, responseType: [Conversation].self, completion: completion)
    }

    func createDirectConversation(
        friendID: Int,
        completion: @escaping (Result<Conversation, NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.createDirectConversation(friendID: friendID),
            responseType: Conversation.self,
            completion: completion
        )
    }

    func fetchMessages(
        conversationID: Int,
        completion: @escaping (Result<[ChatMessage], NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.messages(conversationID: conversationID),
            responseType: [ChatMessage].self,
            completion: completion
        )
    }

    func sendMessage(
        conversationID: Int,
        content: String,
        completion: @escaping (Result<ChatMessage, NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.sendMessage(conversationID: conversationID, content: content),
            responseType: ChatMessage.self,
            completion: completion
        )
    }

    func markConversationRead(
        conversationID: Int,
        completion: @escaping (Result<ReadConversationReceipt, NetworkError>) -> Void
    ) {
        networkClient.request(
            ChatAPI.markConversationRead(conversationID: conversationID),
            responseType: ReadConversationReceipt.self,
            completion: completion
        )
    }
}

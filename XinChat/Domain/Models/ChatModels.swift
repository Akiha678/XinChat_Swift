import Foundation

private let serverDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

/// 服务端用户摘要，同时用于好友和好友候选列表。
struct Contact: Decodable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let avatarColor: Int
}

/// 服务端接受好友申请后返回的回执。
struct FriendRequestReceipt: Decodable {
    let id: Int
}

/// 服务端确认的会话已读位置。
struct ReadConversationReceipt: Decodable {
    let conversationId: Int
    let lastReadMessageId: Int?
}

/// 收到的好友申请，用于收件箱和接受/拒绝操作。
struct FriendRequest: Decodable, Hashable {
    let id: Int
    let requester: Contact
    let addressee: Contact
    let status: String
    let message: String?
    let createdAt: String
}

/// 会话列表展示模型。
struct Conversation: Decodable, Hashable {
    let id: Int
    let peerId: Int
    let name: String
    let preview: String
    let lastMessageAt: String?
    let unreadCount: Int
    let colorSeed: Int

    var time: String {
        guard let lastMessageAt,
              let date = serverDateFormatter.date(from: lastMessageAt) else { return "" }
        return date.formatted(date: .omitted, time: .shortened)
    }
}

/// 服务端聊天消息模型。
struct ChatMessage: Decodable, Hashable {
    let id: Int
    let conversationId: Int
    let senderId: Int
    let content: String
    let type: String
    let createdAt: String

    var text: String { content }
    var isOutgoing: Bool { senderId == AppSession.currentUserID }

    var time: String {
        guard let date = serverDateFormatter.date(from: createdAt) else { return "" }
        return date.formatted(date: .omitted, time: .shortened)
    }
}

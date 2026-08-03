import Foundation

/// 服务端联系人模型。
struct Contact: Decodable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

/// 会话列表展示模型。
struct Conversation: Hashable {
    let id: UUID
    let name: String
    let preview: String
    let time: String
    let unreadCount: Int
    let colorSeed: Int
}

/// 单条聊天消息模型。
struct ChatMessage: Hashable {
    let id: UUID
    let text: String
    let isOutgoing: Bool
    let time: String
}

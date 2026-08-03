import Foundation

struct Contact: Decodable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

struct Conversation: Hashable {
    let id: UUID
    let name: String
    let preview: String
    let time: String
    let unreadCount: Int
    let colorSeed: Int
}

struct ChatMessage: Hashable {
    let id: UUID
    let text: String
    let isOutgoing: Bool
    let time: String
}

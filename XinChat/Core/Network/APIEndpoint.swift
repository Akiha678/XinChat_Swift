import Alamofire

/// 描述一次 API 请求所需的路径、方法和参数。
/// 新增接口时通过遵循该协议接入，无需修改底层 `NetworkClient`。
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

/// 认证模块接口集合。
enum AuthAPI: APIEndpoint {
    case login(username: String, password: String)

    var path: String { "/auth/login" }
    var method: HTTPMethod { .post }
    var parameters: Parameters? {
        switch self {
        case let .login(username, password):
            ["username": username, "password": password]
        }
    }
}

/// 通讯模块当前使用的接口集合。
enum ChatAPI {
    case friends
    case friendCandidates(keyword: String)
    /// 发送好友申请。
    case sendFriendRequest(contactID: Int)
    case conversations
    case createDirectConversation(friendID: Int)
    case messages(conversationID: Int)
    case sendMessage(conversationID: Int, content: String)
}

extension ChatAPI: APIEndpoint {
    var path: String {
        switch self {
        case .friends: "/friends"
        case .friendCandidates: "/users/search"
        case .sendFriendRequest: "/friend-requests"
        case .conversations: "/conversations"
        case .createDirectConversation: "/conversations/direct"
        case let .messages(conversationID): "/conversations/\(conversationID)/messages"
        case let .sendMessage(conversationID, _): "/conversations/\(conversationID)/messages"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .friends, .friendCandidates, .conversations, .messages: .get
        case .sendFriendRequest, .createDirectConversation, .sendMessage: .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .friends:
            ["userId": AppSession.currentUserID]
        case let .friendCandidates(keyword):
            ["currentUserId": AppSession.currentUserID, "keyword": keyword]
        case let .sendFriendRequest(contactID):
            [
                "requesterId": AppSession.currentUserID,
                "addresseeId": contactID,
                "message": "你好，我想添加你为好友"
            ]
        case .conversations:
            ["userId": AppSession.currentUserID]
        case let .createDirectConversation(friendID):
            ["userId": AppSession.currentUserID, "friendId": friendID]
        case .messages:
            ["userId": AppSession.currentUserID, "limit": 50]
        case let .sendMessage(_, content):
            ["senderId": AppSession.currentUserID, "content": content]
        }
    }
}

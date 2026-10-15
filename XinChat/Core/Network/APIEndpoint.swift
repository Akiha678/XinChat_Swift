import Alamofire

/// 描述一次 API 请求所需的路径、方法和参数。
/// 新增接口时通过遵循该协议接入，无需修改底层 `NetworkClient`。
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var requiresAuthentication: Bool { get }
}

extension APIEndpoint {
    var requiresAuthentication: Bool { true }
}

/// 认证模块接口集合。
enum AuthAPI: APIEndpoint {
    case login(username: String, password: String)
    case sendEmailCode(email: String)
    case loginByEmail(email: String, code: String)
    case register(email: String, code: String, password: String)
    case sendPasswordResetCode(email: String)
    case updatePassword(email: String, code: String, newPassword: String)

    var path: String {
        switch self {
        case .login: "/auth/login"
        case .sendEmailCode: "/auth/register/code"
        case .loginByEmail: "/auth/login/email"
        case .register: "/auth/register"
        case .sendPasswordResetCode: "/auth/password/code"
        case .updatePassword: "/auth/updatePassword"
        }
    }

    var method: HTTPMethod { .post }
    var requiresAuthentication: Bool { false }

    var parameters: Parameters? {
        switch self {
        case let .login(username, password):
            ["username": username, "password": password]
        case let .sendEmailCode(email):
            ["email": email]
        case let .loginByEmail(email, code):
            ["email": email, "code": code]
        case let .register(email, code, password):
            ["email": email, "code": code, "password": password]
        case let .sendPasswordResetCode(email):
            ["email": email]
        case let .updatePassword(email, code, newPassword):
            ["email": email, "code": code, "newPassword": newPassword]
        }
    }
}

/// 通讯模块当前使用的接口集合。
enum ChatAPI {
    case friends
    case friendCandidates(keyword: String)
    /// 发送好友申请。
    case sendFriendRequest(contactID: Int)
    case incomingFriendRequests
    case acceptFriendRequest(requestID: Int)
    case rejectFriendRequest(requestID: Int)
    case conversations
    case createDirectConversation(friendID: Int)
    case messages(conversationID: Int)
    case sendMessage(conversationID: Int, content: String)
    case markConversationRead(conversationID: Int)
}

extension ChatAPI: APIEndpoint {
    var path: String {
        switch self {
        case .friends: "/friends"
        case .friendCandidates: "/users/search"
        case .sendFriendRequest: "/friend-requests"
        case .incomingFriendRequests: "/friend-requests/incoming"
        case let .acceptFriendRequest(requestID): "/friend-requests/\(requestID)/accept"
        case let .rejectFriendRequest(requestID): "/friend-requests/\(requestID)/reject"
        case .conversations: "/conversations"
        case .createDirectConversation: "/conversations/direct"
        case let .messages(conversationID): "/conversations/\(conversationID)/messages"
        case let .sendMessage(conversationID, _): "/conversations/\(conversationID)/messages"
        case let .markConversationRead(conversationID): "/conversations/\(conversationID)/read"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .friends, .friendCandidates, .incomingFriendRequests, .conversations, .messages: .get
        case .sendFriendRequest, .acceptFriendRequest, .rejectFriendRequest,
             .createDirectConversation, .sendMessage, .markConversationRead: .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .friends:
            nil
        case let .friendCandidates(keyword):
            ["username": keyword]
        case let .sendFriendRequest(contactID):
            [
                "addresseeId": contactID,
                "message": "你好，我想添加你为好友"
            ]
        case .incomingFriendRequests, .acceptFriendRequest, .rejectFriendRequest,
             .markConversationRead:
            nil
        case .conversations:
            nil
        case let .createDirectConversation(friendID):
            ["friendId": friendID]
        case .messages:
            ["limit": 50]
        case let .sendMessage(_, content):
            ["content": content]
        }
    }
}

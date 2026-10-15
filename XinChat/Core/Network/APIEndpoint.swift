import Alamofire

/// 描述一次 API 请求所需的路径、方法和参数。
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var requiresAuthentication: Bool { get }
}

extension APIEndpoint {
    var requiresAuthentication: Bool { true }
}

/// 认证模块接口集合（严格对齐 API.md 与扩展端点）。
enum AuthAPI: APIEndpoint {
    case login(username: String, password: String)
    case sendEmailLoginCode(email: String)
    case sendRegisterCode(email: String)
    case loginByEmail(email: String, code: String)
    case register(email: String, code: String, password: String)
    case sendPasswordResetCode(email: String)
    case updatePassword(email: String, code: String, newPassword: String)

    var path: String {
        switch self {
        case .login: "/auth/login"
        case .sendEmailLoginCode: "/auth/login/emailCode"
        case .sendRegisterCode: "/auth/register/code"
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
        case let .sendEmailLoginCode(email), let .sendRegisterCode(email):
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

/// 通讯与好友模块接口集合（严格对齐 API.md）。
enum ChatAPI {
    case friends
    case friendCandidates(keyword: String)
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
        case .friends: "/contact/friends"
        case .friendCandidates: "/contact/users/search"
        case .sendFriendRequest: "/contact/friend-requests"
        case .incomingFriendRequests: "/contact/friend-requests/incoming"
        case let .acceptFriendRequest(requestID): "/contact/friend-requests/\(requestID)/accept"
        case let .rejectFriendRequest(requestID): "/contact/friend-requests/\(requestID)/reject"
        case .conversations: "/chat/session"
        case .createDirectConversation: "/chat/conversation"
        case .messages: "/chat/message/page"
        case let .sendMessage(conversationID, _): "/chat/session/\(conversationID)/message"
        case .markConversationRead: "/chat/message/read"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .friends, .friendCandidates, .incomingFriendRequests, .conversations: .get
        case .sendFriendRequest, .acceptFriendRequest, .rejectFriendRequest,
             .createDirectConversation, .messages, .sendMessage, .markConversationRead: .post
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
        case .incomingFriendRequests, .acceptFriendRequest, .rejectFriendRequest:
            nil
        case .conversations:
            nil
        case let .createDirectConversation(friendID):
            ["friendId": friendID]
        case let .messages(conversationID):
            [
                "sessionId": conversationID,
                "page": 1,
                "size": 50
            ]
        case let .sendMessage(_, content):
            ["content": content]
        case let .markConversationRead(conversationID):
            ["ids": [conversationID]]
        }
    }
}

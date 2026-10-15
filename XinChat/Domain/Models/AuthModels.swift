import Foundation

/// 登录成功用户。可安全持久化的公开资料，不包含密码或令牌。
struct AuthenticatedUser: Codable, Equatable {
    let id: Int
    let username: String
    let displayName: String
    let email: String
    let avatarColor: Int
}

/// 登录接口响应。访问令牌只会转存到 Keychain。
struct LoginResponse: Decodable {
    let id: Int
    let username: String
    let displayName: String
    let email: String
    let avatarColor: Int
    let accessToken: String
    let expiresAt: String

    var session: AuthenticatedSession {
        AuthenticatedSession(
            user: AuthenticatedUser(
                id: id,
                username: username,
                displayName: displayName,
                email: email,
                avatarColor: avatarColor
            ),
            accessToken: accessToken,
            expiresAt: expiresAt
        )
    }
}

struct AuthenticatedSession: Equatable {
    let user: AuthenticatedUser
    let accessToken: String
    let expiresAt: String
}

/// 通用网络响应包装模型，兼容带包装或裸响应
struct GenericNetworkResponse<T: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let data: T?
}

/// 任意内容可解码的占位响应
struct EmptyResponse: Decodable {}

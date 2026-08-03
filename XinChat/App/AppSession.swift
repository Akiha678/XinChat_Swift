import Foundation

/// 当前登录上下文。只持久化公开用户资料，不保存密码。
enum AppSession {
    private static let storageKey = "xinchat.authenticated-user"
    private static var storedUser: AuthenticatedUser? = loadStoredUser()
    private static var storedToken: String? = KeychainStore.loadToken()

    static var currentUser: AuthenticatedUser? {
        storedToken == nil ? nil : storedUser
    }
    static var accessToken: String? { storedToken }

    /// 业务页面只会在登录后创建；若组装流程错误，尽早暴露问题而不是使用错误用户发送消息。
    static var currentUserID: Int {
        guard let id = currentUser?.id else {
            preconditionFailure("访问聊天业务前必须先登录")
        }
        return id
    }

    @discardableResult
    static func signIn(_ session: AuthenticatedSession) -> Bool {
        guard KeychainStore.saveToken(session.accessToken) else { return false }
        storedUser = session.user
        storedToken = session.accessToken
        if let data = try? JSONEncoder().encode(session.user) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        return true
    }

    static func signOut() {
        storedUser = nil
        storedToken = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
        KeychainStore.deleteToken()
    }

    private static func loadStoredUser() -> AuthenticatedUser? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(AuthenticatedUser.self, from: data)
    }
}

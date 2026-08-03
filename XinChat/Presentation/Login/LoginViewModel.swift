import Foundation

/// 登录页面状态和输入校验。
final class LoginViewModel {
    private let repository: AuthRepositoryProtocol

    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onLoginSucceeded: ((AuthenticatedSession) -> Void)?

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func login(username: String?, password: String?) {
        let normalizedUsername = username?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let normalizedPassword = password ?? ""
        guard !normalizedUsername.isEmpty, !normalizedPassword.isEmpty else {
            onError?("请输入用户名和密码")
            return
        }

        onLoadingChanged?(true)
        repository.login(username: normalizedUsername, password: normalizedPassword) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case let .success(session): self?.onLoginSucceeded?(session)
            case let .failure(error): self?.onError?(error.localizedDescription)
            }
        }
    }
}

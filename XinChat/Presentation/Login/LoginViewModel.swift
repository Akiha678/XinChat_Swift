import Foundation

/// 登录模式枚举
enum LoginMode {
    case verificationCode
    case password

    var title: String {
        switch self {
        case .verificationCode: "验证码登录"
        case .password: "密码登录"
        }
    }

    var primaryButtonTitle: String {
        switch self {
        case .verificationCode: "获取验证码"
        case .password: "下一步"
        }
    }

    var switchModeTitle: String {
        switch self {
        case .verificationCode: "密码登录"
        case .password: "验证码登录"
        }
    }
}

/// 登录页面 ViewModel
final class LoginViewModel {
    let repository: AuthRepositoryProtocol

    private(set) var mode: LoginMode = .verificationCode {
        didSet {
            onModeChanged?(mode)
        }
    }

    var isAgreementChecked: Bool = false

    var onModeChanged: ((LoginMode) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onToast: ((String) -> Void)?
    var onLoginSucceeded: ((AuthenticatedSession) -> Void)?

    init(repository: AuthRepositoryProtocol, initialMode: LoginMode = .verificationCode) {
        self.repository = repository
        self.mode = initialMode
    }

    func toggleMode() {
        mode = (mode == .verificationCode) ? .password : .verificationCode
    }

    func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: trimmed)
    }

    func sendCode(email: String, completion: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidEmail(normalizedEmail) else {
            onError?("请输入有效的邮箱地址")
            completion(false)
            return
        }

        onLoadingChanged?(true)
        repository.sendEmailCode(email: normalizedEmail) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case let .success(message):
                self?.onToast?(message)
                completion(true)
            case let .failure(error):
                self?.onError?(error.localizedDescription)
                completion(false)
            }
        }
    }
}

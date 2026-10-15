import SnapKit
import UIKit

/// 密码登录第二步：输入密码页面
final class PasswordInputViewController: UIViewController {
    var onLoginSucceeded: ((AuthenticatedSession) -> Void)?
    var onSwitchToVerifyCode: (() -> Void)?
    var onFindAccount: (() -> Void)?

    private let account: String
    private let repository: AuthRepositoryProtocol

    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let accountLabel = UILabel()
    private let switchAccountButton = UIButton(type: .system)
    private let passwordField = UnderlineTextFieldView(placeholder: "输入密码", isSecure: true, returnKeyType: .go)
    private let loginButton = UIButton(type: .system)
    private let indicator = UIActivityIndicatorView(style: .medium)
    private let bottomLinksStack = UIStackView()
    private let verifyCodeLoginButton = UIButton(type: .system)
    private let findAccountButton = UIButton(type: .system)

    init(account: String, repository: AuthRepositoryProtocol) {
        self.account = account
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        passwordField.becomeFirstResponder()
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.authBackground

        let backConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        titleLabel.text = "输入密码"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label

        accountLabel.text = "账号：\(account)"
        accountLabel.font = .systemFont(ofSize: 14)
        accountLabel.textColor = .secondaryLabel

        switchAccountButton.setTitle("切换账号", for: .normal)
        switchAccountButton.titleLabel?.font = .systemFont(ofSize: 14)
        switchAccountButton.setTitleColor(AppTheme.authLinkBlue, for: .normal)
        switchAccountButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let accountRow = UIStackView(arrangedSubviews: [accountLabel, switchAccountButton])
        accountRow.axis = .horizontal
        accountRow.spacing = 10
        accountRow.alignment = .center

        passwordField.onTextChanged = { [weak self] text in
            self?.updateButtonState(password: text)
        }
        passwordField.onReturnPressed = { [weak self] in
            self?.loginTapped()
        }

        loginButton.setTitle("登录", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        updateButtonState(password: "")

        verifyCodeLoginButton.setTitle("验证码登录", for: .normal)
        verifyCodeLoginButton.titleLabel?.font = .systemFont(ofSize: 14)
        verifyCodeLoginButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        verifyCodeLoginButton.addTarget(self, action: #selector(switchToVerifyCodeTapped), for: .touchUpInside)

        findAccountButton.setTitle("账号找回", for: .normal)
        findAccountButton.titleLabel?.font = .systemFont(ofSize: 14)
        findAccountButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        findAccountButton.addTarget(self, action: #selector(findAccountTapped), for: .touchUpInside)

        bottomLinksStack.axis = .horizontal
        bottomLinksStack.distribution = .equalSpacing
        bottomLinksStack.addArrangedSubview(verifyCodeLoginButton)
        bottomLinksStack.addArrangedSubview(findAccountButton)

        [backButton, titleLabel, accountRow, passwordField, loginButton, indicator, bottomLinksStack].forEach(view.addSubview)

        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(18)
            $0.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(28)
        }

        accountRow.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(28)
        }

        passwordField.snp.makeConstraints {
            $0.top.equalTo(accountRow.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(52)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(48)
        }

        indicator.snp.makeConstraints {
            $0.center.equalTo(loginButton)
        }

        bottomLinksStack.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
    }

    private func updateButtonState(password: String) {
        let isReady = !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        loginButton.isEnabled = isReady
        loginButton.backgroundColor = isReady ? AppTheme.authPrimaryButton : AppTheme.authDisabledButton
        loginButton.setTitleColor(isReady ? AppTheme.authPrimaryButtonText : AppTheme.authDisabledButtonText, for: .normal)
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func loginTapped() {
        let password = passwordField.text
        guard !password.isEmpty else { return }

        passwordField.resignFirstResponder()
        setLoading(true)

        repository.login(username: account, password: password) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)
            switch result {
            case let .success(session):
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.onLoginSucceeded?(session)
            case let .failure(error):
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                self.showError(error.localizedDescription)
                self.passwordField.becomeFirstResponder()
            }
        }
    }

    @objc private func switchToVerifyCodeTapped() {
        onSwitchToVerifyCode?()
        backTapped()
    }

    @objc private func findAccountTapped() {
        onFindAccount?()
    }

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loginButton.setTitle(loading ? nil : "登录", for: .normal)
        loading ? indicator.startAnimating() : indicator.stopAnimating()
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "登录失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

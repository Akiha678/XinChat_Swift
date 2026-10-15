import SnapKit
import UIKit

/// 账号找回与密码重置页面
final class ResetPasswordViewController: UIViewController {
    private let repository: AuthRepositoryProtocol
    private let defaultEmail: String

    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let emailField = UnderlineTextFieldView(placeholder: "输入邮箱地址", keyboardType: .emailAddress)
    private let codeField = UnderlineTextFieldView(placeholder: "输入邮箱验证码", keyboardType: .numberPad)
    private let getCodeButton = UIButton(type: .system)
    private let newPasswordField = UnderlineTextFieldView(placeholder: "设置新密码", isSecure: true, returnKeyType: .done)
    private let submitButton = UIButton(type: .system)
    private let indicator = UIActivityIndicatorView(style: .medium)

    private var countdownTimer: Timer?
    private var remainingSeconds = 60

    init(repository: AuthRepositoryProtocol, email: String = "") {
        self.repository = repository
        self.defaultEmail = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        countdownTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if !defaultEmail.isEmpty {
            emailField.text = defaultEmail
        }
        updateSubmitState()
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.authBackground

        let backConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        titleLabel.text = "账号找回"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label

        subtitleLabel.text = "通过已绑定的邮箱验证并重置密码"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel

        getCodeButton.setTitle("获取验证码", for: .normal)
        getCodeButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        getCodeButton.setTitleColor(AppTheme.authLinkBlue, for: .normal)
        getCodeButton.addTarget(self, action: #selector(getCodeTapped), for: .touchUpInside)

        emailField.onTextChanged = { [weak self] _ in self?.updateSubmitState() }
        codeField.onTextChanged = { [weak self] _ in self?.updateSubmitState() }
        newPasswordField.onTextChanged = { [weak self] _ in self?.updateSubmitState() }
        newPasswordField.onReturnPressed = { [weak self] in self?.submitTapped() }

        submitButton.setTitle("重置密码", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        let codeContainer = UIView()
        codeContainer.addSubview(codeField)
        codeContainer.addSubview(getCodeButton)

        codeField.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(getCodeButton.snp.leading).offset(-12)
        }

        getCodeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-4)
            $0.width.greaterThanOrEqualTo(80)
        }

        [backButton, titleLabel, subtitleLabel, emailField, codeContainer, newPasswordField, submitButton, indicator].forEach(view.addSubview)

        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(18)
            $0.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(28)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }

        emailField.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(52)
        }

        codeContainer.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(52)
        }

        newPasswordField.snp.makeConstraints {
            $0.top.equalTo(codeContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(52)
        }

        submitButton.snp.makeConstraints {
            $0.top.equalTo(newPasswordField.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(48)
        }

        indicator.snp.makeConstraints {
            $0.center.equalTo(submitButton)
        }
    }

    private func updateSubmitState() {
        let email = emailField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = codeField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pwd = newPasswordField.text
        let isReady = isValidEmail(email) && !code.isEmpty && pwd.count >= 6

        submitButton.isEnabled = isReady
        submitButton.backgroundColor = isReady ? AppTheme.authPrimaryButton : AppTheme.authDisabledButton
        submitButton.setTitleColor(isReady ? AppTheme.authPrimaryButtonText : AppTheme.authDisabledButtonText, for: .normal)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func getCodeTapped() {
        let email = emailField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidEmail(email) else {
            showToast("请输入有效的邮箱地址")
            return
        }

        startCountdown()
        repository.sendPasswordResetCode(email: email) { [weak self] result in
            switch result {
            case let .success(message):
                self?.showToast(message)
            case let .failure(error):
                self?.showToast(error.localizedDescription)
            }
        }
    }

    private func startCountdown() {
        remainingSeconds = 60
        getCodeButton.isEnabled = false
        getCodeButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        getCodeButton.setTitle("\(remainingSeconds)s", for: .normal)

        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                timer.invalidate()
                self.getCodeButton.isEnabled = true
                self.getCodeButton.setTitleColor(AppTheme.authLinkBlue, for: .normal)
                self.getCodeButton.setTitle("重新获取", for: .normal)
            } else {
                self.getCodeButton.setTitle("\(self.remainingSeconds)s", for: .normal)
            }
        }
    }

    @objc private func submitTapped() {
        let email = emailField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = codeField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pwd = newPasswordField.text

        view.endEditing(true)
        setLoading(true)

        repository.resetPassword(email: email, code: code, newPassword: pwd) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)
            switch result {
            case .success:
                let alert = UIAlertController(title: "重置成功", message: "密码已重置，请返回使用新密码登录", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                    self.backTapped()
                }))
                self.present(alert, animated: true)
            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        submitButton.isEnabled = !loading
        submitButton.setTitle(loading ? nil : "重置密码", for: .normal)
        loading ? indicator.startAnimating() : indicator.stopAnimating()
    }

    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "操作失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

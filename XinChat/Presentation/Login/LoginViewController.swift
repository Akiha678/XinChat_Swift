import SnapKit
import UIKit

/// 账号密码登录页面。
final class LoginViewController: UIViewController {
    var onLoginSucceeded: ((AuthenticatedSession) -> Void)?

    private let viewModel: LoginViewModel
    private let logoView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let formView = UIView()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let indicator = UIActivityIndicatorView(style: .medium)
    private let testAccountLabel = UILabel()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        logoView.image = UIImage(systemName: "message.fill")
        logoView.tintColor = AppTheme.tint
        logoView.contentMode = .scaleAspectFit

        titleLabel.text = "XinChat"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .center
        subtitleLabel.text = "登录后与好友保持联系"
        subtitleLabel.textColor = AppTheme.secondaryText
        subtitleLabel.textAlignment = .center

        formView.backgroundColor = .systemBackground
        formView.layer.cornerRadius = 18
        formView.layer.shadowColor = UIColor.black.cgColor
        formView.layer.shadowOpacity = 0.06
        formView.layer.shadowRadius = 14
        formView.layer.shadowOffset = CGSize(width: 0, height: 6)

        configure(field: usernameField, placeholder: "用户名", icon: "person")
        usernameField.textContentType = .username
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.returnKeyType = .next
        usernameField.delegate = self

        configure(field: passwordField, placeholder: "密码", icon: "lock")
        passwordField.textContentType = .password
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .go
        passwordField.delegate = self

        loginButton.setTitle("登录", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        loginButton.backgroundColor = AppTheme.tint
        loginButton.layer.cornerRadius = 12
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        testAccountLabel.text = "测试账号：admin1 / admin2　密码：123456"
        testAccountLabel.font = .systemFont(ofSize: 13)
        testAccountLabel.textColor = AppTheme.secondaryText
        testAccountLabel.textAlignment = .center
        testAccountLabel.numberOfLines = 0

        [logoView, titleLabel, subtitleLabel, formView, loginButton, indicator, testAccountLabel].forEach(view.addSubview)
        [usernameField, passwordField].forEach(formView.addSubview)

        logoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(54)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(72)
        }
        titleLabel.snp.makeConstraints { $0.top.equalTo(logoView.snp.bottom).offset(16); $0.centerX.equalToSuperview() }
        subtitleLabel.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(8); $0.centerX.equalToSuperview() }
        formView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(112)
        }
        usernameField.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        passwordField.snp.makeConstraints {
            $0.top.equalTo(usernameField.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        loginButton.snp.makeConstraints {
            $0.top.equalTo(formView.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(formView)
            $0.height.equalTo(50)
        }
        indicator.snp.makeConstraints { $0.center.equalTo(loginButton) }
        testAccountLabel.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(18)
            $0.leading.trailing.equalTo(formView)
        }
    }

    private func configure(field: UITextField, placeholder: String, icon: String) {
        field.placeholder = placeholder
        field.font = .systemFont(ofSize: 16)
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = AppTheme.secondaryText
        imageView.contentMode = .center
        imageView.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        field.leftView = imageView
        field.leftViewMode = .always
        field.layer.borderColor = UIColor.separator.cgColor
        field.layer.borderWidth = 0.5
    }

    private func bind() {
        viewModel.onLoadingChanged = { [weak self] loading in
            self?.loginButton.isEnabled = !loading
            self?.loginButton.setTitle(loading ? nil : "登录", for: .normal)
            loading ? self?.indicator.startAnimating() : self?.indicator.stopAnimating()
        }
        viewModel.onError = { [weak self] message in self?.showError(message) }
        viewModel.onLoginSucceeded = { [weak self] user in self?.onLoginSucceeded?(user) }
    }

    @objc private func loginTapped() {
        view.endEditing(true)
        viewModel.login(username: usernameField.text, password: passwordField.text)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "登录失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField {
            passwordField.becomeFirstResponder()
        } else {
            loginTapped()
        }
        return true
    }
}

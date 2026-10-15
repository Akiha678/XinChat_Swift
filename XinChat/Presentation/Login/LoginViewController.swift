import SnapKit
import UIKit

/// 登录主页面（复刻小黑盒风格，支持验证码登录与密码登录切换，无显式注册页，未注册邮箱自动注册）
final class LoginViewController: UIViewController {
    var onLoginSucceeded: ((AuthenticatedSession) -> Void)?

    private let viewModel: LoginViewModel

    // UI 组件
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let emailField = UnderlineTextFieldView(placeholder: "输入邮箱", keyboardType: .emailAddress, returnKeyType: .next)
    private let primaryButton = UIButton(type: .system)
    private let indicator = UIActivityIndicatorView(style: .medium)

    // 辅助切换行
    private let subActionsStack = UIStackView()
    private let switchModeButton = UIButton(type: .system)
    private let findAccountButton = UIButton(type: .system)

    // 底部区域
    private let agreementCheckboxView = AgreementCheckboxView()
    private let thirdPartyLoginView = ThirdPartyLoginView()
    private let brandFooterView = BrandFooterView()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        updateUI(for: viewModel.mode, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.authBackground

        // 关闭按钮
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: closeConfig), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        // 标题
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label

        // 邮箱输入框
        emailField.onTextChanged = { [weak self] text in
            self?.updatePrimaryButtonState(email: text)
        }
        emailField.onReturnPressed = { [weak self] in
            self?.primaryButtonTapped()
        }

        // 主操作按钮
        primaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        primaryButton.layer.cornerRadius = 8
        primaryButton.clipsToBounds = true
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)

        // 辅助操作（切换登录方式、账号找回）
        switchModeButton.titleLabel?.font = .systemFont(ofSize: 14)
        switchModeButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        switchModeButton.addTarget(self, action: #selector(switchModeTapped), for: .touchUpInside)

        findAccountButton.setTitle("账号找回", for: .normal)
        findAccountButton.titleLabel?.font = .systemFont(ofSize: 14)
        findAccountButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        findAccountButton.addTarget(self, action: #selector(findAccountTapped), for: .touchUpInside)

        subActionsStack.axis = .horizontal
        subActionsStack.distribution = .equalSpacing
        subActionsStack.alignment = .center
        subActionsStack.addArrangedSubview(switchModeButton)
        subActionsStack.addArrangedSubview(findAccountButton)

        // 用户协议
        agreementCheckboxView.onCheckedChanged = { [weak self] checked in
            self?.viewModel.isAgreementChecked = checked
        }
        agreementCheckboxView.onUserAgreementTapped = { [weak self] in
            self?.openPolicy(type: .userAgreement)
        }
        agreementCheckboxView.onPrivacyPolicyTapped = { [weak self] in
            self?.openPolicy(type: .privacyPolicy)
        }

        // 第三方登录
        thirdPartyLoginView.onAppleLoginTapped = { [weak self] in
            self?.showToast("暂未开放Apple登录，请使用邮箱登录")
        }
        thirdPartyLoginView.onWechatLoginTapped = { [weak self] in
            self?.showToast("暂未开放微信登录，请使用邮箱登录")
        }

        [
            closeButton,
            titleLabel,
            emailField,
            primaryButton,
            indicator,
            subActionsStack,
            agreementCheckboxView,
            thirdPartyLoginView,
            brandFooterView
        ].forEach(view.addSubview)

        layoutViews()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func layoutViews() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(18)
            $0.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(28)
        }

        emailField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(52)
        }

        primaryButton.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(48)
        }

        indicator.snp.makeConstraints {
            $0.center.equalTo(primaryButton)
        }

        subActionsStack.snp.makeConstraints {
            $0.top.equalTo(primaryButton.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(28)
        }

        brandFooterView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.centerX.equalToSuperview()
        }

        thirdPartyLoginView.snp.makeConstraints {
            $0.bottom.equalTo(brandFooterView.snp.top).offset(-24)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(44)
        }

        agreementCheckboxView.snp.makeConstraints {
            $0.bottom.equalTo(thirdPartyLoginView.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
    }

    private func bindViewModel() {
        viewModel.onModeChanged = { [weak self] mode in
            self?.updateUI(for: mode, animated: true)
        }

        viewModel.onLoadingChanged = { [weak self] loading in
            self?.primaryButton.isEnabled = !loading
            self?.primaryButton.setTitle(loading ? nil : self?.viewModel.mode.primaryButtonTitle, for: .normal)
            loading ? self?.indicator.startAnimating() : self?.indicator.stopAnimating()
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }

        viewModel.onToast = { [weak self] message in
            self?.showToast(message)
        }

        viewModel.onLoginSucceeded = { [weak self] session in
            self?.onLoginSucceeded?(session)
        }
    }

    private func updateUI(for mode: LoginMode, animated: Bool) {
        let updateBlock = {
            self.titleLabel.text = mode.title
            self.primaryButton.setTitle(mode.primaryButtonTitle, for: .normal)
            self.switchModeButton.setTitle(mode.switchModeTitle, for: .normal)
            self.updatePrimaryButtonState(email: self.emailField.text)
        }

        if animated {
            UIView.transition(with: titleLabel, duration: 0.2, options: .transitionCrossDissolve, animations: updateBlock)
        } else {
            updateBlock()
        }
    }

    private func updatePrimaryButtonState(email: String) {
        let isReady = viewModel.isValidEmail(email)
        primaryButton.isEnabled = isReady
        primaryButton.backgroundColor = isReady ? AppTheme.authPrimaryButton : AppTheme.authDisabledButton
        primaryButton.setTitleColor(isReady ? AppTheme.authPrimaryButtonText : AppTheme.authDisabledButtonText, for: .normal)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func closeTapped() {
        dismissKeyboard()
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            showToast("请完成登录以继续使用")
        }
    }

    @objc private func switchModeTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        viewModel.toggleMode()
    }

    @objc private func findAccountTapped() {
        dismissKeyboard()
        let resetVC = ResetPasswordViewController(
            repository: viewModel.repository,
            email: emailField.text
        )
        navigateOrPresent(resetVC)
    }

    @objc private func primaryButtonTapped() {
        dismissKeyboard()
        let email = emailField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard viewModel.isValidEmail(email) else {
            showError("请输入有效的邮箱地址")
            return
        }

        // 验证码登录流程必须先勾选协议（符合图2中的协议勾选设计）
        if viewModel.mode == .verificationCode && !viewModel.isAgreementChecked {
            agreementCheckboxView.shake()
            showToast("请先阅读并同意用户协议和隐私政策")
            return
        }

        switch viewModel.mode {
        case .verificationCode:
            // 验证码登录：发送验证码后进入输入验证码界面
            viewModel.sendCode(email: email) { [weak self] success in
                guard success, let self else { return }
                let verifyVC = VerifyCodeInputViewController(email: email, repository: self.viewModel.repository)
                verifyVC.onLoginSucceeded = { [weak self] session in
                    self?.onLoginSucceeded?(session)
                }
                self.navigateOrPresent(verifyVC)
            }

        case .password:
            // 密码登录：点击下一步进入输入密码界面
            let passwordVC = PasswordInputViewController(account: email, repository: viewModel.repository)
            passwordVC.onLoginSucceeded = { [weak self] session in
                self?.onLoginSucceeded?(session)
            }
            passwordVC.onSwitchToVerifyCode = { [weak self] in
                self?.viewModel.toggleMode()
            }
            passwordVC.onFindAccount = { [weak self] in
                self?.findAccountTapped()
            }
            navigateOrPresent(passwordVC)
        }
    }

    private func navigateOrPresent(_ vc: UIViewController) {
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

    private func openPolicy(type: PolicyWebViewController.PolicyType) {
        let policyVC = PolicyWebViewController(type: type)
        policyVC.modalPresentationStyle = .pageSheet
        present(policyVC, animated: true)
    }

    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }

    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

import SnapKit
import UIKit

/// 输入邮箱验证码页面（支持自动注册与登录回调）
final class VerifyCodeInputViewController: UIViewController {
    var onLoginSucceeded: ((AuthenticatedSession) -> Void)?

    private let email: String
    private let repository: AuthRepositoryProtocol
    private let codeLength = 6

    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let hiddenTextField = UITextField()
    private let boxesStack = UIStackView()
    private var codeBoxes: [UILabel] = []
    private let countdownButton = UIButton(type: .system)
    private let indicator = UIActivityIndicatorView(style: .medium)

    private var countdownTimer: Timer?
    private var remainingSeconds = 60

    init(email: String, repository: AuthRepositoryProtocol) {
        self.email = email
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        countdownTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startCountdown()
        hiddenTextField.becomeFirstResponder()
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.authBackground

        let backConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        titleLabel.text = "输入验证码"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label

        subtitleLabel.text = "验证码已发送至 \(email)"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        // 隐藏的输入框用于捕获键盘输入与短信/邮件验证码自动填充
        hiddenTextField.keyboardType = .numberPad
        hiddenTextField.textContentType = .oneTimeCode
        hiddenTextField.delegate = self
        hiddenTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        hiddenTextField.alpha = 0.01

        boxesStack.axis = .horizontal
        boxesStack.distribution = .fillEqually
        boxesStack.spacing = 10
        boxesStack.alignment = .center

        for i in 0..<codeLength {
            let label = UILabel()
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 24, weight: .bold)
            label.textColor = .label
            label.layer.cornerRadius = 8
            label.layer.borderWidth = 1.5
            label.layer.borderColor = AppTheme.authBorder.cgColor
            label.backgroundColor = .secondarySystemBackground
            label.clipsToBounds = true
            label.tag = i

            boxesStack.addArrangedSubview(label)
            codeBoxes.append(label)

            label.snp.makeConstraints {
                $0.height.equalTo(52)
            }
        }

        countdownButton.setTitle("60s 后重新获取", for: .normal)
        countdownButton.titleLabel?.font = .systemFont(ofSize: 14)
        countdownButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        countdownButton.isEnabled = false
        countdownButton.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)

        [backButton, titleLabel, subtitleLabel, hiddenTextField, boxesStack, countdownButton, indicator].forEach(view.addSubview)

        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(18)
            $0.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(28)
            $0.trailing.equalToSuperview().inset(28)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }

        hiddenTextField.snp.makeConstraints {
            $0.top.leading.equalTo(boxesStack)
            $0.size.equalTo(1)
        }

        boxesStack.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(52)
        }

        countdownButton.snp.makeConstraints {
            $0.top.equalTo(boxesStack.snp.bottom).offset(24)
            $0.leading.equalTo(boxesStack)
        }

        indicator.snp.makeConstraints {
            $0.center.equalTo(boxesStack)
        }

        updateBoxesHighlight(currentIndex: 0)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func viewTapped() {
        hiddenTextField.becomeFirstResponder()
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func resendTapped() {
        remainingSeconds = 60
        startCountdown()

        repository.sendEmailCode(email: email) { [weak self] result in
            switch result {
            case let .success(message):
                self?.showToast(message)
            case let .failure(error):
                self?.showToast(error.localizedDescription)
            }
        }
    }

    private func startCountdown() {
        countdownButton.isEnabled = false
        countdownButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        countdownButton.setTitle("\(remainingSeconds)s 后重新获取", for: .normal)

        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                timer.invalidate()
                self.countdownButton.isEnabled = true
                self.countdownButton.setTitleColor(AppTheme.authLinkBlue, for: .normal)
                self.countdownButton.setTitle("重新获取验证码", for: .normal)
            } else {
                self.countdownButton.setTitle("\(self.remainingSeconds)s 后重新获取", for: .normal)
            }
        }
    }

    @objc private func textDidChange() {
        guard let text = hiddenTextField.text else { return }
        let trimmed = String(text.prefix(codeLength))
        if trimmed != text {
            hiddenTextField.text = trimmed
        }

        let characters = Array(trimmed)
        for i in 0..<codeLength {
            if i < characters.count {
                codeBoxes[i].text = String(characters[i])
            } else {
                codeBoxes[i].text = ""
            }
        }

        updateBoxesHighlight(currentIndex: characters.count)

        if characters.count == codeLength {
            submitCode(trimmed)
        }
    }

    private func updateBoxesHighlight(currentIndex: Int) {
        for (i, box) in codeBoxes.enumerated() {
            if i == currentIndex {
                box.layer.borderColor = AppTheme.authUnderlineFocused.cgColor
                box.backgroundColor = .systemBackground
            } else {
                box.layer.borderColor = AppTheme.authBorder.cgColor
                box.backgroundColor = .secondarySystemBackground
            }
        }
    }

    private func submitCode(_ code: String) {
        hiddenTextField.resignFirstResponder()
        indicator.startAnimating()
        boxesStack.alpha = 0.5

        repository.loginByEmail(email: email, code: code) { [weak self] result in
            guard let self else { return }
            self.indicator.stopAnimating()
            self.boxesStack.alpha = 1.0

            switch result {
            case let .success(session):
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.onLoginSucceeded?(session)
            case let .failure(error):
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                self.showError(error.localizedDescription)
                self.hiddenTextField.text = ""
                self.textDidChange()
                self.hiddenTextField.becomeFirstResponder()
            }
        }
    }

    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "登录失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

extension VerifyCodeInputViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= codeLength && (string.isEmpty || CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)))
    }
}

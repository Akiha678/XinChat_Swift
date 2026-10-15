import SnapKit
import UIKit

/// 极简下划线输入框，完美复刻小黑盒风格
final class UnderlineTextFieldView: UIView {
    var text: String {
        get { textField.text ?? "" }
        set {
            textField.text = newValue
            updateRightViews()
        }
    }

    var onTextChanged: ((String) -> Void)?
    var onReturnPressed: (() -> Void)?

    let textField = UITextField()
    private let underlineView = UIView()
    private let rightStack = UIStackView()
    private let clearButton = UIButton(type: .custom)
    private let eyeButton = UIButton(type: .custom)
    private let isSecureMode: Bool

    init(
        placeholder: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .emailAddress,
        returnKeyType: UIReturnKeyType = .done
    ) {
        self.isSecureMode = isSecure
        super.init(frame: .zero)
        setupViews(placeholder: placeholder, keyboardType: keyboardType, returnKeyType: returnKeyType)
    }

    required init?(coder: NSCoder) { nil }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    private func setupViews(
        placeholder: String,
        keyboardType: UIKeyboardType,
        returnKeyType: UIReturnKeyType
    ) {
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.textColor = .label
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = keyboardType
        textField.returnKeyType = returnKeyType
        textField.isSecureTextEntry = isSecureMode
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        underlineView.backgroundColor = AppTheme.authUnderlineNormal

        rightStack.axis = .horizontal
        rightStack.spacing = 12
        rightStack.alignment = .center

        // 清除按钮
        let clearConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: clearConfig), for: .normal)
        clearButton.tintColor = UIColor.tertiaryLabel
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.isHidden = true
        rightStack.addArrangedSubview(clearButton)

        // 密码显隐眼睛按钮
        if isSecureMode {
            let eyeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            eyeButton.setImage(UIImage(systemName: "eye.slash", withConfiguration: eyeConfig), for: .normal)
            eyeButton.setImage(UIImage(systemName: "eye", withConfiguration: eyeConfig), for: .selected)
            eyeButton.tintColor = UIColor.secondaryLabel
            eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
            rightStack.addArrangedSubview(eyeButton)
        }

        addSubview(textField)
        addSubview(rightStack)
        addSubview(underlineView)

        rightStack.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(textField)
        }

        textField.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.equalTo(rightStack.snp.leading).offset(-8)
            $0.height.equalTo(44)
        }

        underlineView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    @objc private func textDidChange() {
        updateRightViews()
        onTextChanged?(text)
    }

    @objc private func clearTapped() {
        textField.text = ""
        updateRightViews()
        onTextChanged?("")
    }

    @objc private func togglePasswordVisibility() {
        eyeButton.isSelected.toggle()
        textField.isSecureTextEntry = !eyeButton.isSelected
        // 保持光标位置不被置换
        if let selectedRange = textField.selectedTextRange {
            textField.selectedTextRange = nil
            textField.selectedTextRange = selectedRange
        }
    }

    private func updateRightViews() {
        clearButton.isHidden = !textField.isFirstResponder || text.isEmpty
    }

    private func setUnderlineFocused(_ focused: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.underlineView.backgroundColor = focused ? AppTheme.authUnderlineFocused : AppTheme.authUnderlineNormal
            self.underlineView.snp.updateConstraints {
                $0.height.equalTo(focused ? 1.5 : 1)
            }
            self.layoutIfNeeded()
        }
    }
}

extension UnderlineTextFieldView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setUnderlineFocused(true)
        updateRightViews()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        setUnderlineFocused(false)
        updateRightViews()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnPressed?()
        return true
    }
}

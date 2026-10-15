import SnapKit
import UIKit

/// 用户协议与隐私政策勾选组件，完全匹配小黑盒样式
final class AgreementCheckboxView: UIView {
    var isChecked: Bool = false {
        didSet {
            updateCheckboxIcon()
            onCheckedChanged?(isChecked)
        }
    }

    var onCheckedChanged: ((Bool) -> Void)?
    var onUserAgreementTapped: (() -> Void)?
    var onPrivacyPolicyTapped: (() -> Void)?

    private let checkboxButton = UIButton(type: .custom)
    private let textView = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { nil }

    private func setupViews() {
        updateCheckboxIcon()
        checkboxButton.addTarget(self, action: #selector(toggleChecked), for: .touchUpInside)

        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.linkTextAttributes = [
            .foregroundColor: AppTheme.authLinkBlue,
            .underlineStyle: 0
        ]

        let fullText = "我已阅读并同意《用户协议》和《隐私政策》"
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )

        let agreementRange = (fullText as NSString).range(of: "《用户协议》")
        if agreementRange.location != NSNotFound {
            attributedString.addAttribute(.link, value: "agreement://user", range: agreementRange)
        }

        let privacyRange = (fullText as NSString).range(of: "《隐私政策》")
        if privacyRange.location != NSNotFound {
            attributedString.addAttribute(.link, value: "privacy://policy", range: privacyRange)
        }

        textView.attributedText = attributedString

        addSubview(checkboxButton)
        addSubview(textView)

        checkboxButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        textView.snp.makeConstraints {
            $0.leading.equalTo(checkboxButton.snp.trailing).offset(6)
            $0.trailing.top.bottom.equalToSuperview()
        }
    }

    @objc private func toggleChecked() {
        isChecked.toggle()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func updateCheckboxIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let iconName = isChecked ? "checkmark.circle.fill" : "circle"
        let icon = UIImage(systemName: iconName, withConfiguration: config)
        checkboxButton.setImage(icon, for: .normal)
        checkboxButton.tintColor = isChecked ? UIColor.label : UIColor.systemGray3
    }

    /// 未勾选时的左右抖动提醒动画
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-8, 8, -6, 6, -3, 3, 0]
        layer.add(animation, forKey: "shake")

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

extension AgreementCheckboxView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if URL.scheme == "agreement" {
            onUserAgreementTapped?()
            return false
        } else if URL.scheme == "privacy" {
            onPrivacyPolicyTapped?()
            return false
        }
        return true
    }
}

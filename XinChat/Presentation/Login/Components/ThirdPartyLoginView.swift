import SnapKit
import UIKit

/// 底部第三方登录选项按钮集合（Apple 登录、微信登录）
final class ThirdPartyLoginView: UIView {
    var onAppleLoginTapped: (() -> Void)?
    var onWechatLoginTapped: (() -> Void)?

    private let appleButton = UIButton(type: .system)
    private let wechatButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { nil }

    private func setupViews() {
        configureCapsule(
            button: appleButton,
            title: "通过Apple登录",
            symbolName: "apple.logo",
            symbolColor: .label
        )
        appleButton.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)

        configureCapsule(
            button: wechatButton,
            title: "微信登录",
            symbolName: "message.fill",
            symbolColor: UIColor(red: 0.03, green: 0.77, blue: 0.38, alpha: 1)
        )
        wechatButton.addTarget(self, action: #selector(wechatTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [appleButton, wechatButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16

        addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }

    private func configureCapsule(
        button: UIButton,
        title: String,
        symbolName: String,
        symbolColor: UIColor
    ) {
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authBorder.cgColor

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: symbolName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.baseForegroundColor = .label

        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: 14, weight: .regular)
        config.attributedTitle = titleAttr
        button.configuration = config
    }

    @objc private func appleTapped() {
        onAppleLoginTapped?()
    }

    @objc private func wechatTapped() {
        onWechatLoginTapped?()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        appleButton.layer.borderColor = AppTheme.authBorder.cgColor
        wechatButton.layer.borderColor = AppTheme.authBorder.cgColor
    }
}

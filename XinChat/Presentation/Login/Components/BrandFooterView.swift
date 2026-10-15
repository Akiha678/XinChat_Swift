import SnapKit
import UIKit

/// 页面底部品牌标识组件（Logo + XinChat 文字，完美还原小黑盒底部）
final class BrandFooterView: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { nil }

    private func setupViews() {
        if let appIcon = UIImage(named: "xinchat_logo") {
            iconView.image = appIcon
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
            iconView.image = UIImage(systemName: "message.badge.filled.fill", withConfiguration: config)
        }
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label

        titleLabel.text = "XinChat"
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .label

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center

        addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }

        iconView.snp.makeConstraints {
            $0.size.equalTo(18)
        }
    }
}

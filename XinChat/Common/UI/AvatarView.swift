import SnapKit
import UIKit

/// 可复用的文字头像组件，根据名称首字符和种子值生成稳定外观。
final class AvatarView: UIView {
    private let titleLabel = UILabel()

    init(size: CGFloat = 48) {
        super.init(frame: .zero)
        layer.cornerRadius = size * 0.28
        clipsToBounds = true
        titleLabel.font = .systemFont(ofSize: size * 0.4, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        snp.makeConstraints { $0.size.equalTo(size) }
    }

    required init?(coder: NSCoder) { nil }

    /// 更新头像文字及背景色。
    /// - Parameters:
    ///   - name: 用于生成头像首字符的显示名称。
    ///   - seed: 用于稳定选择主题色的数值。
    func configure(name: String, seed: Int) {
        titleLabel.text = String(name.prefix(1)).uppercased()
        backgroundColor = AppTheme.avatarColors[abs(seed) % AppTheme.avatarColors.count]
    }
}

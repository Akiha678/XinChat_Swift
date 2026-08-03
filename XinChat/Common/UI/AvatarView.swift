import SnapKit
import UIKit

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

    func configure(name: String, seed: Int) {
        titleLabel.text = String(name.prefix(1)).uppercased()
        backgroundColor = AppTheme.avatarColors[abs(seed) % AppTheme.avatarColors.count]
    }
}

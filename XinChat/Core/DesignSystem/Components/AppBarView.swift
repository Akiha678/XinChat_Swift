import SnapKit
import UIKit

/// 业务页面统一使用的顶部导航组件。
///
/// AppBar 负责标题、返回按钮、右侧操作按钮和底部分隔线的布局，页面仅注入点击行为。
final class AppBarView: UIView {
    /// AppBar 的标准内容高度，不包含系统安全区。
    static let contentHeight: CGFloat = 52

    var onBackTapped: (() -> Void)?
    var onRightTapped: (() -> Void)?

    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let separatorView = UIView()

    init(
        title: String,
        showsBackButton: Bool = true,
        rightImage: UIImage? = nil
    ) {
        super.init(frame: .zero)
        setupUI()
        setTitle(title)
        backButton.isHidden = !showsBackButton
        setRightImage(rightImage)
    }

    required init?(coder: NSCoder) { nil }

    /// 更新居中的页面标题。
    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    /// 更新右侧操作图标；传入 `nil` 时隐藏按钮。
    func setRightImage(_ image: UIImage?) {
        rightButton.setImage(image, for: .normal)
        rightButton.isHidden = image == nil
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = AppTheme.primaryText
        titleLabel.textAlignment = .center

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppTheme.tint
        backButton.accessibilityLabel = "返回"
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        rightButton.tintColor = AppTheme.tint
        rightButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        separatorView.backgroundColor = .separator

        [titleLabel, backButton, rightButton, separatorView].forEach(addSubview)

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(rightButton.snp.leading).offset(-8)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    @objc private func backTapped() { onBackTapped?() }
    @objc private func rightTapped() { onRightTapped?() }
}

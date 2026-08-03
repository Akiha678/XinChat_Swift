import SnapKit
import UIKit

/// 个人中心基础页面，展示用户资料和常用功能入口。
final class ProfileViewController: UIViewController {
    private let user: AuthenticatedUser
    private let onLogout: () -> Void
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let profileCard = UIView()
    private let avatarView = AvatarView(size: 72)
    private let nameLabel = UILabel()
    private let accountLabel = UILabel()
    private let menuStack = UIStackView()
    private let logoutButton = UIButton(type: .system)

    init(user: AuthenticatedUser, onLogout: @escaping () -> Void) {
        self.user = user
        self.onLogout = onLogout
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Layout

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        profileCard.backgroundColor = .systemBackground
        profileCard.layer.cornerRadius = 16
        avatarView.configure(name: user.displayName, seed: user.avatarColor)
        nameLabel.text = user.displayName
        nameLabel.font = .systemFont(ofSize: 21, weight: .bold)
        accountLabel.text = "XinChat ID：\(user.username)"
        accountLabel.font = .systemFont(ofSize: 14)
        accountLabel.textColor = AppTheme.secondaryText
        menuStack.axis = .vertical
        menuStack.spacing = 1
        menuStack.layer.cornerRadius = 14
        menuStack.clipsToBounds = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(profileCard)
        [avatarView, nameLabel, accountLabel].forEach(profileCard.addSubview)
        contentView.addSubview(menuStack)

        let rows = [
            ("star.fill", "收藏", UIColor.systemYellow),
            ("folder.fill", "文件", UIColor.systemBlue),
            ("gearshape.fill", "设置", UIColor.systemGray)
        ]
        rows.forEach { icon, title, color in
            menuStack.addArrangedSubview(makeMenuRow(icon: icon, title: title, color: color))
        }

        logoutButton.setTitle("退出登录", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        logoutButton.backgroundColor = .systemBackground
        logoutButton.layer.cornerRadius = 14
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        contentView.addSubview(logoutButton)

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview()
        }
        profileCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(112)
        }
        avatarView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarView.snp.trailing).offset(16)
            $0.top.equalToSuperview().offset(29)
            $0.trailing.equalToSuperview().inset(18)
        }
        accountLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        menuStack.snp.makeConstraints {
            $0.top.equalTo(profileCard.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(profileCard)
        }
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(menuStack.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(profileCard)
            $0.height.equalTo(52)
        }
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "退出登录", message: "确定要退出当前账号吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in self?.onLogout() })
        present(alert, animated: true)
    }

    /// 创建样式统一的个人中心菜单行。
    private func makeMenuRow(icon: String, title: String, color: UIColor) -> UIView {
        let row = UIView()
        row.backgroundColor = .systemBackground
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = color
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        [imageView, label, chevron].forEach(row.addSubview)
        row.snp.makeConstraints { $0.height.equalTo(54) }
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        label.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(13)
            $0.centerY.equalToSuperview()
        }
        chevron.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        return row
    }
}

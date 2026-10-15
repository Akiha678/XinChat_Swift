import SnapKit
import UIKit

/// 用户协议与隐私政策查看页面
final class PolicyWebViewController: UIViewController {
    enum PolicyType {
        case userAgreement
        case privacyPolicy

        var title: String {
            switch self {
            case .userAgreement: "用户服务协议"
            case .privacyPolicy: "隐私政策"
            }
        }

        var content: String {
            switch self {
            case .userAgreement:
                """
                欢迎使用 XinChat 通讯服务！

                一、特别提示
                在使用 XinChat 服务之前，请您仔细阅读本《用户服务协议》（以下简称“本协议”）。若您使用 XinChat，即表示您已充分理解并同意接受本协议的全部条款。

                二、账号注册与使用
                1. 本应用支持邮箱快速登录，首次登录将自动为您完成账号创建。
                2. 您有义务妥善保管您的登录凭证与账户信息。
                3. 用户不得利用本服务制作、复制、发布、传播违法违规、骚扰、诽谤等不良信息。

                三、知识产权与服务终止
                XinChat 拥有产品全部知识产权。如发现恶意攻击、群发骚扰消息或盗用他人身份的行为，系统有权注销或封禁相关账号。

                四、协议修改
                我们可能会适时修改本协议，修订后的协议一经公布即生效。
                """
            case .privacyPolicy:
                """
                XinChat 隐私保护指引

                我们非常重视用户的隐私和个人信息保护。本指引旨在向您说明我们如何收集、使用和保护您的个人信息：

                一、信息收集与使用
                1. 账号信息：登录时我们收集您的邮箱地址，用于身份验证、接收安全验证码及账户安全保障。
                2. 个人资料：您可以选择设置昵称与头像，用于好友识别与通讯交流。
                3. 消息通讯：为了向您提供即时通讯服务，我们会传输您发送的文字与多媒体消息，传输过程使用端到端加密保障。

                二、数据存储与安全
                1. 您的登录凭证通过 iOS Keychain 硬件级安全存储。
                2. 我们绝不会向任何未经授权的第三方出售或共享您的个人隐私数据。

                三、您的权利
                您可以随时在“我的”页面修改您的个人信息、更新密码或退出登录。
                """
            }
        }
    }

    private let policyType: PolicyType
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let closeButton = UIButton(type: .system)

    init(type: PolicyType) {
        self.policyType = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        titleLabel.text = policyType.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center

        closeButton.setTitle("完成", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        closeButton.tintColor = AppTheme.tint
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        let headerView = UIView()
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        let divider = UIView()
        divider.backgroundColor = .separator

        textView.text = policyType.content
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 24, right: 20)

        view.addSubview(headerView)
        view.addSubview(divider)
        view.addSubview(textView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        divider.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        textView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

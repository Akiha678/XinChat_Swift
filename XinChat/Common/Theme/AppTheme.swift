import UIKit

/// 应用视觉令牌，集中维护颜色，避免业务页面散落硬编码样式。
enum AppTheme {
    static let tint = UIColor(red: 0.12, green: 0.49, blue: 0.96, alpha: 1)
    static let background = UIColor.systemGroupedBackground
    static let card = UIColor.secondarySystemGroupedBackground
    static let primaryText = UIColor.label
    static let secondaryText = UIColor.secondaryLabel

    static let avatarColors: [UIColor] = [
        tint,
        UIColor.systemTeal,
        UIColor.systemOrange,
        UIColor.systemIndigo,
        UIColor.systemPink
    ]

    // 登录模块视觉令牌（黑白极简风格）
    static let authBackground = UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.08, alpha: 1) : .systemBackground
    }
    static let authPrimaryButton = UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : UIColor(white: 0.08, alpha: 1)
    }
    static let authPrimaryButtonText = UIColor { trait in
        trait.userInterfaceStyle == .dark ? .black : .white
    }
    static let authDisabledButton = UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.16, alpha: 1) : UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    }
    static let authDisabledButtonText = UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.4, alpha: 1) : UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1)
    }
    static let authBorder = UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.22, alpha: 1) : UIColor(red: 0.88, green: 0.88, blue: 0.90, alpha: 1)
    }
    static let authUnderlineNormal = UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.20, alpha: 1) : UIColor(red: 0.91, green: 0.91, blue: 0.93, alpha: 1)
    }
    static let authUnderlineFocused = UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : UIColor(white: 0.12, alpha: 1)
    }
    static let authLinkBlue = UIColor(red: 0.18, green: 0.46, blue: 0.88, alpha: 1)
}

import UIKit

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
}

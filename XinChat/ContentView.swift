//
//  ContentView.swift
//  XinChat
//
//  Created by 陈鑫 on 2026/8/3.
//

import SwiftUI
import UIKit

/// SwiftUI
struct ContentView: View {
    var body: some View {
        RootViewControllerRepresentable()
            .ignoresSafeArea()  /// 让UIKit页面铺满整个屏幕
    }
}

/// 业务界面使用UIKit
/// UIView -> SwiftUI的桥接器：把UIKit的UIViewController包装成SwiftUI可以识别的View
private struct RootViewControllerRepresentable: UIViewControllerRepresentable {
    ///
    func makeUIViewController(context: Context) -> UIViewController {
        AppContainer.shared.makeRootViewController()
    }
    /// UIKit页面自己管理状态，不需要SwiftUI驱动更新
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

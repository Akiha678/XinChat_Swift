//
//  ContentView.swift
//  XinChat
//
//  Created by 陈鑫 on 2026/8/3.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        RootViewControllerRepresentable()
            .ignoresSafeArea()
    }
}

/// 将 UIKit 根控制器接入 SwiftUI 生命周期。
/// 业务页面仍全部使用 UIKit，避免在页面层混用两套布局体系。
private struct RootViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        AppContainer.shared.makeRootViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

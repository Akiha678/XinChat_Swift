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

private struct RootViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        AppContainer.shared.makeRootViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


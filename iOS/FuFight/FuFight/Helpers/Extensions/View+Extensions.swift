//
//  View+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/18/24.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    public func toUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
#if targetEnvironment(macCatalyst)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
#else
        var window: UIWindow? {
            guard let scene = UIApplication.shared.connectedScenes.first,
                  let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
                  let window = windowSceneDelegate.window else {
                return nil
            }
            return window
        }

        if let window = window, let rootViewController = window.rootViewController {
            var topController = rootViewController
            while let newTopController = topController.presentedViewController {
                topController = newTopController
            }
            topController.view.insertSubview(controller.view, at: controller.view.subviews.count)
        } else {
            print("cant access window")
        }
#endif
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        // here is the call to the function that converts UIView to UIImage: `.asImage()`
        let image = controller.view.asImage()
        controller.view.removeFromSuperview()
        return image
    }
}
#endif

//
//  SceneDelegate.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let vc = CalculatroVC()
        window.rootViewController = vc
        self.window = window
        window.makeKeyAndVisible()
    }
}


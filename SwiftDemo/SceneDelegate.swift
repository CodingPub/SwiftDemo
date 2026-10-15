//
//  SceneDelegate.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2026/10/15.
//  Copyright © 2026 Xiaobin Lin. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        window?.rootViewController?.view.backgroundColor = UIColor.white
    }
}

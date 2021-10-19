//
//  SceneDelegate.swift
//  PlaygroundForAppleUIKit
//
//  Created by Jake Barnby on 7/10/21.
//
import Appwrite
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
            url.absoluteString.contains("appwrite-callback") else {
            return
        }
        WebAuthComponent.handleIncomingCookie(from: url)
    }
}


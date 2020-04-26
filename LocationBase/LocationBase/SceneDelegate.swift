//
//  SceneDelegate.swift
//  LocationBase
//
//  Created by Irfan Filipovic on 4/18/20.

//  Last modified by: IF
//  Last modified on: 04/26/20
//
//  Handles changes in scene
//      1. Connects view to window on connection
//      2. Reloads view to application on background, continues location updates.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Loads Main.storyboard, on load ViewController.swift functions are invoked
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Reload ViewController to continue location tracking
        //  1. Raises error as there is no background task to terminate
        //  2. Continues regardless with no negative effect
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}


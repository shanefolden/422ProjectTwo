//
//  AppDelegate.swift
//  LocationBase

//  Created by Irfan Filipovic on 4/18/20.

//  Last modified by: IF
//  Last modified on: 04/26/20


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle
    
    // Creates application configuration
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // Uses info.plist to build a configuration
        // Including:
        //  1. Background modes
        //  2. Location authorization states
        //  3. Main.storyboard as Application view
        //  4. LaunchScreen.storyboard as View on Load/Launch

        return UISceneConfiguration(name: "LocationBase", sessionRole: connectingSceneSession.role)
    }
}


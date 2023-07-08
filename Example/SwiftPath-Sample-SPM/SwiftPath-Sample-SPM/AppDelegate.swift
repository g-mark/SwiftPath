//
//  AppDelegate.swift
//  SwiftPath-Sample-SPM
//
//  Created by Steven Grosmark on 11/15/20.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = ViewController()
            window.makeKeyAndVisible()
        }
        return true
    }

}


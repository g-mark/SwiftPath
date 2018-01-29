//
//  AppDelegate.swift
//  SwiftPath Example
//
//  Created by Steven Grosmark on 1/28/18.
//  Copyright © 2018 Steven Grosmark. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            let firstViewController = FeedsViewController()
            let navigationController = UINavigationController(rootViewController: firstViewController)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        
        return true
    }

}


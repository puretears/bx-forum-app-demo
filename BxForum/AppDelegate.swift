//
//  AppDelegate.swift
//  BxForum
//
//  Created by Mars on 2018/9/25.
//  Copyright © 2018 Mars. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    self.window = UIWindow(frame: UIScreen.main.bounds)
  
    if let window = window {
      let bxForumVC = BxForumViewController()
      let mainVC = ViewController(rootViewController: bxForumVC)
      
      window.rootViewController = mainVC
      window.makeKeyAndVisible()
    }
  
    return true
  }
}


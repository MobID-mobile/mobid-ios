//
//  AppDelegate.swift
//  MobID
//
//  Created by AleksandrPavliuk on 12/22/2020.
//  Copyright (c) 2020 AleksandrPavliuk. All rights reserved.
//

import UIKit
import MobID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
                    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    MobID.configure(
      scheme: "https",
      hostName: "api.mobid.ai",
      username: "admin",
      password: "admin123"
    )

    return true
  }
}


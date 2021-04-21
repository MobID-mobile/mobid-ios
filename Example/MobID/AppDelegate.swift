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

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let config = MobIDConfig(
      scheme: "https",
      hostName: "api.mobid.ai",
      username: "fae6f2b2-0586-4b96-9dfe-5ab5ee014112",
      password: "xXbyVU9LabFTCN9"
    )
    MobID.configure(with: config)

    return true
  }
}


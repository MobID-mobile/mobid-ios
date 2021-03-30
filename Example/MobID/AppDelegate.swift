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

    MobID.configure(host: MobIDHost(scheme: "https", name: "api.mobid.ai"))
    MobID.delegate = self

    return true
  }
}

extension AppDelegate: MobIDDelegate {
  func verificationStatus(_ status: VerificationStatus) {
    print(status)
  }

  func errorOccurred(_ error: ClientError) {
    print(error)
  }
}


//
//  ViewController.swift
//  MobID
//
//  Created by AleksandrPavliuk on 12/22/2020.
//  Copyright (c) 2020 AleksandrPavliuk. All rights reserved.
//

import UIKit
import MobID

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    MobID.delegate = self

    MobID.getOpenConferences() { [weak self] result in
      switch result {
      case let .success(openConferences):
        DispatchQueue.main.async {
          let startViewController = StartViewController()
          startViewController.conferenceID = openConferences.first?.conferenceID
          self?.navigationController?.pushViewController(startViewController, animated: true)
        }
      case .failure(_):
        break
      }
    }
  }
}


extension ViewController: MobIDDelegate {
  func verificationStatus(_ status: VerificationStatus) {
    print(status)
  }

  func errorOccurred(_ error: ClientError) {
    print(error)
  }
}

//
//  UIAlertController+MOBID.swift
//  MobID
//
//  Created by admin on 10.12.2020.
//

import UIKit

// MARK: - Add/remove child
extension UIViewController {
  func add(child: UIViewController) {
    addChild(child)
    view.addSubview(child.view)
    child.didMove(toParent: self)
  }

  func remove() {
    guard parent != nil else { return }
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}

// MARK: - Alerts
extension UIViewController {
  func showMessageAlert(title: String?,
                        message: String? = nil,
                        buttonTitle: String? = "Ok",
                        action: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
      if let action = action { action() }
    })
    self.present(alert, animated: true, completion: nil)
  }

  func showErrorAlert() {
    let alert = UIAlertController(
      title: "Something went wrong",
      message: nil,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
    self.present(alert, animated: true, completion: nil)
  }

  func showConfirmationAlert(title: String?,
                             message: String? = nil,
                             buttonFirstTitle: String? = "Ok",
                             buttonSecondTitle: String? = "Cancel",
                             firstAction: (() -> Void)? = nil,
                             secondAction: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: buttonFirstTitle, style: .default) { _ in
      if let action = firstAction { action() }
    })
    alert.addAction(UIAlertAction(title: buttonSecondTitle, style: .default) { _ in
      if let action = secondAction { action() }
    })
    self.present(alert, animated: true, completion: nil)
  }

  func showActionSheetAlert(title: String?,
                            message: String?,
                            buttonTitle: String?,
                            cancelButtonTitle: String? = "Cancel",
                            action: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
      action?()
    })

    alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel))
    self.present(alert, animated: true, completion: nil)
  }

}

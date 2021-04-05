//  Created by admin on 10.12.2020.


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

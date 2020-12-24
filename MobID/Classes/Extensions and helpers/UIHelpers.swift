//  Created by admin on 09.12.2020.

import UIKit

private final class BundleToken {}

private var bundle: Bundle {
  return Bundle(for: BundleToken.self)
}

extension UIColor {
  static var brandColor: UIColor? {
    return UIColor(named: "brandColor", in: bundle, compatibleWith: nil)
  }
}

extension UIImage {
  static var logo: UIImage? {
    return UIImage(named: "logo", in: bundle, compatibleWith: nil)
  }
}

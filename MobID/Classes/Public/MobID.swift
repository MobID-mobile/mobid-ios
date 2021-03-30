//  Created by admin on 18.03.2021.

import Foundation

public struct MobIDHost {
  public init(scheme: String, name: String) {
    self.scheme = scheme
    self.name = name
  }
  
  public let scheme: String
  public let name: String
}

public class MobID {
  public static func configure(host: MobIDHost) {
    EndpointRouter.host = host.name
    EndpointRouter.scheme = host.scheme
  }
}

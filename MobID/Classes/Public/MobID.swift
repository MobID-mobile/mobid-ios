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

public protocol MobIDDelegate {
  func verificationStatus(_ status: VerificationStatus)
  func errorOccurred(_ error: ClientError)
}

public class MobID {

  // MARK: - Public
  public static var delegate: MobIDDelegate?


  // MARK: - Private
  private static let networkClient = Client()

  // MARK: - Public
  public static func configure(host: MobIDHost) {
    EndpointRouter.host = host.name
    EndpointRouter.scheme = host.scheme
  }

  public static func getOpenConferences(completion: @escaping (Result<OpenConferences, ClientError>)-> Void) {
    networkClient.openConferences {
      completion($0.result)
    }
  }
}

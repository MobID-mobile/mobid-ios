//  Created by admin on 18.03.2021.

import Foundation

public struct MobIDConfig {
  public init(scheme: String, hostName: String, username: String, password: String) {
    self.scheme = scheme
    self.hostName = hostName
    self.username = username
    self.password = password
  }
  
  public let scheme: String
  public let hostName: String
  public let username: String
  public let password: String
}

public protocol MobIDDelegate {
  func verificationStatus(_ status: VerificationStatus)
  func errorOccurred(_ error: ClientError)
}

public class MobID {

  // MARK: - Public
  public static var delegate: MobIDDelegate?

  // MARK: - Private
  private static let networkService = NetworkService()

  // MARK: - Public
  public static func configure(with config: MobIDConfig) {
    EndpointRouter.host = config.hostName
    EndpointRouter.scheme = config.scheme
    EndpointRouter.username = config.username
    EndpointRouter.password = config.password
  }

  public static func getOpenConferences(completion: @escaping (Result<OpenConferences, ClientError>)-> Void) {
    networkService.tokenAuth { error in
      if let error = error {
        completion(.failure(error))
      } else {
        networkService.openConferences {
          completion($0.result)
        }
      }
    }
  }
}

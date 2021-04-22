//  Created by admin on 18.03.2021.

import Foundation

struct MobIDConfig {
  static var scheme: String?
  static var host: String?
  static var token: String = ""
  static var verificationID: String = ""
  static var username: String = ""
  static var password: String = ""
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
  public static func configure(scheme: String, hostName: String, username: String, password: String) {
    MobIDConfig.host = hostName
    MobIDConfig.scheme = scheme
    MobIDConfig.username = username
    MobIDConfig.password = password
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

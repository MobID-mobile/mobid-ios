//  Created by admin on 23.12.2020.

import Foundation

enum EndpointRouter: HTTPEndpoint {

  static var scheme: String?
  static var host: String?
  static var token: String = ""
  static var verificationID: String = ""
  static var username: String = ""
  static var password: String = ""

  case auth(parameters: HTTPParameters)
  case verification
  case patchVerification(parameters: HTTPParameters)
  case openConferences
  case tokenAuth(parameters: HTTPParameters)
}

extension EndpointRouter {
  var scheme: String {
    guard let scheme = Self.scheme else {
      assertionFailure("Scheme should exist")
      return ""
    }
    return scheme
  }

  var host: String {
    guard let host = Self.host else {
      assertionFailure("Host should exist")
      return ""
    }

    return host
  }

  var port: Int? {
    return nil
  }

  var queryItems: HTTPQueryItems? {
    switch self {
    case .auth, .verification, .patchVerification, .openConferences, .tokenAuth:
      return nil
    }
  }

  var path: String {
    switch self {
    case .auth:
      return "/api/v1.1/verifications/"
    case .verification,
         .patchVerification:
      return "/api/v1.1/verifications/" + Self.verificationID + "/"
    case .openConferences:
      return "/api/v1.1/open_conferences/"
    case .tokenAuth:
      return "/api-token-auth/"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .auth,
         .tokenAuth:
      return .post
    case .verification,
         .openConferences:
      return .get
    case .patchVerification:
      return .patch
    }
  }

  var params: HTTPParameters? {
    switch self {
    case let .auth(parameters),
         let .patchVerification(parameters),
         let .tokenAuth(parameters):
      return parameters
    case .verification,
         .openConferences:
      return nil
    }
  }

  var headers: HTTPHeaders {
    switch self {
    case .tokenAuth:
      return [:]
    case .verification,
         .patchVerification,
         .auth,
         .openConferences:
      return ["authorization": "Bearer \(Self.token)"]
    }
  }
}

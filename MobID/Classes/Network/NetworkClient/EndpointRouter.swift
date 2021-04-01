//  Created by admin on 23.12.2020.

import Foundation

enum EndpointRouter: HTTPEndpoint {

  static var scheme: String?
  static var host: String?
  static var token: String = ""
  static var verificationID: String = ""

  case auth(parameters: HTTPParameters)
  case verification
  case photo(parameters: HTTPParameters)
  case patchVerification(parameters: HTTPParameters)
  case openConferences
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
    case .auth, .verification, .photo, .patchVerification, .openConferences:
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
    case .photo:
      return "/api/v1.1/verifications/" + Self.verificationID + "/images/"
    case .openConferences:
      return "/api/v1.1/open_conferences/"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .auth,
         .photo:
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
         let .photo(parameters),
         let .patchVerification(parameters):
      return parameters
    case .verification,
         .openConferences:
      return nil
    }
  }

  var headers: HTTPHeaders {
    switch self {
    case .auth,
         .openConferences:
      return [:]
    case .verification,
         .photo,
         .patchVerification:
      return ["authorization": "Bearer \(Self.token)"]
    }
  }
}

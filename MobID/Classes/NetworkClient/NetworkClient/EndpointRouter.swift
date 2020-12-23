//  Created by admin on 23.12.2020.

import Foundation

enum EndpointRouter: HTTPEndpoint {

  static var host: String?
  static var token: String = ""
  static var id: String = ""

  case auth(parameters: HTTPParameters)
  case verification
}

extension EndpointRouter {
  var scheme: String {
    return "https"
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
    case .auth, .verification:
      return nil
    }
  }

  var path: String {
    switch self {
    case .auth:
      return "/api/v1.1/verifications/"
    case .verification:
      return "/api/v1.1/verifications/" + Self.id + "/"

    }
  }

  var method: HTTPMethod {
    switch self {
    case .auth:
      return .post
    case .verification:
      return .get
    }
  }

  var params: HTTPParameters? {
    switch self {
    case let .auth(parameters):
      return parameters
    case .verification:
      return nil
    }
  }

  var headers: HTTPHeaders {
    switch self {
    case .auth:
      return [:]
    case .verification:
      return ["authorization": "Bearer \(Self.token)"]
    }
  }
}

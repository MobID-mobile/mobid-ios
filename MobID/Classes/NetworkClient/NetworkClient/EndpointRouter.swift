//  Created by admin on 23.12.2020.

import Foundation

enum EndpointRouter: HTTPEndpoint {

  static var host: String?
  static var token: String?
  static var id: String?

  case verification(parameters: HTTPParameters)
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
    case .verification:
      return nil
    }
  }

  var path: String {
    switch self {
    case .verification:
      return "/api/v1.1/verifications/"

    }
  }

  var method: HTTPMethod {
    switch self {
    case .verification:
      return .post
    }
  }

  var params: HTTPParameters? {
    switch self {
    case let .verification(parameters):
      return parameters

    }
  }

  var headers: HTTPHeaders {
    return [:]
  }
}

//  Created by admin on 23.12.2020.

import Foundation

enum Endpoint: HTTPEndpoint {
  case ad(host: String, queryItems: HTTPQueryItems)
}

extension Endpoint {
  var scheme: String {
    return "https"
  }

  var host: String {
    switch self {
    case .ad(let host, _):
      return host
    }
  }

  var port: Int? {
    return nil
  }

  var queryItems: HTTPQueryItems? {
    switch self {
    case .ad(_, let queryItems):
      return queryItems
    }
  }

  var path: String {
    switch self {
    case .ad:
      return "/app"

    }
  }

  var method: HTTPMethod {
    switch self {
    case .ad:
      return .get
    }
  }

  var params: HTTPParameters? {
    switch self {
    case .ad:
      return nil

    }
  }

  var headers: HTTPHeaders {
    return [:]
  }
}

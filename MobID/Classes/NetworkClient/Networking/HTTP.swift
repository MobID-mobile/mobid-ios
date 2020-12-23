//  Created by admin on 23.12.2020.

import Foundation

typealias HTTPParameters = [String: Any]
typealias HTTPQueryItems = [String: String]
typealias HTTPHeaders = [String: String]

enum HTTPMethod: String {
  case get        = "GET"
  case head       = "HEAD"
  case post       = "POST"
  case put        = "PUT"
  case options    = "OPTIONS"
  case patch      = "PATCH"
  case delete     = "DELETE"
  case trace      = "TRACE"
  case connect    = "CONNECT"
}

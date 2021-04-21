//  Created by admin on 23.12.2020.

import Foundation

protocol URLRequestConvertible {
  func asURLRequest() throws -> URLRequest
}

enum EndpointError: LocalizedError {
  case invalidURL(description: String)

  var errorDescription: String? {
    switch self {
    case .invalidURL(let description):
      return description
    }
  }
}

protocol HTTPEndpoint: URLRequestConvertible {
  var scheme: String { get }
  var host: String { get }
  var port: Int? { get }

  var path: String { get }
  var method: HTTPMethod { get }
  var params: HTTPParameters? { get }
  var headers: HTTPHeaders { get }
  var queryItems: HTTPQueryItems? { get }
}

extension HTTPEndpoint {

  func asURLRequest() throws -> URLRequest {
    let url = try fullURL()

    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try params.map { try JSONSerialization.data(withJSONObject: $0) }
    request.httpMethod = method.rawValue

    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }

    return request
  }

  private func fullURL() throws -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.port = port
    urlComponents.path = path
    urlComponents.queryItems = queryItems?.map { URLQueryItem(name: $0, value: $1) }
    guard let url = urlComponents.url else {
      print(urlComponents.debugDescription)
      throw EndpointError.invalidURL(description: urlComponents.debugDescription)
    }

    return url
  }
}

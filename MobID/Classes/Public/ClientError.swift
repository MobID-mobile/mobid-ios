//  Created by admin on 23.12.2020.

import Foundation

public enum ClientError: LocalizedError {
  case endpointError(error: Error)
  case networkError(error: URLSessionError)
  case serverError(statusCode: Int)
  case parsingError(error: Error)
  case dataIsEmptyError

  public var errorDescription: String? {
    switch self {
    case .endpointError(let endpointError):
      return "Endpoint error: \(endpointError.localizedDescription)"
    case .networkError(let networkError):
      return "Network error: \(networkError.localizedDescription)"
    case .serverError(let statusCode):
      return "Server error \(statusCode)"
    case .parsingError(let parsingError):
      return "Parsing error: \(parsingError.localizedDescription)"
    case .dataIsEmptyError:
      return "Response data is empty"
    }
  }
}

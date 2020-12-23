//  Created by admin on 23.12.2020.

import Foundation

class Client {

  required init(domain: String,
                id: String,
                sessionManager: URLSessionManager = URLSessionManager(configuration: URLSessionConfiguration.default),
                queue: DispatchQueue = DispatchQueue(label: "mobID.Network.Client." + UUID().uuidString)) {
    self.sessionManager = sessionManager
    self.queue = queue
    self.domain = domain
    self.id = id
  }


  let sessionManager: URLSessionManager
  let queue: DispatchQueue
  let domain: String
  let id: String

  @discardableResult
  func perform(_ requestConvertible: URLRequestConvertible,
               completion: @escaping (Result<String, ClientError>) -> Void) -> URLSessionDataTask? {
    do {
      let request = try requestConvertible.asURLRequest()
      return sessionManager.perform(request: request) { [weak self] (response) in
        guard let self = self else { return }
        self.queue.async {
          let result: Result<String, ClientError> = response.result
            .flatMap(ifSuccess: self.verifyServerResponse, ifFailure: self.networkErrorToResult)
            .flatMap(ifSuccess: self.parseResult, ifFailure: liftError)

          completion(result)
        }
      }
    } catch {
      completion(.failure(.endpointError(error: error)))
      return nil
    }
  }
  
  func verifyServerResponse(_ response: (data: Data?, urlResponse: HTTPURLResponse)) -> Result<Data?, ClientError> {
    if (200..<300).contains(response.urlResponse.statusCode) {
      return .success(response.0)
    } else {
      return .failure(.serverError(statusCode: response.urlResponse.statusCode))
    }
  }

  func parseResult(_ data: Data?) -> Result<String, ClientError> {
    guard let data = data, !data.isEmpty else {
      return .failure(.dataIsEmptyError)
    }

    let decodedData = String(data: data, encoding: .utf8)
    if let decodedData = decodedData {
      return .success(decodedData)
    } else {
      return .failure(.parsingError)
    }
  }

  func networkErrorToResult(_ error: URLSessionError) -> Result<Data?, ClientError> {
    return .failure(.networkError(error: error))
  }
}

// MARK: - Concrete methods
extension Client {

  @discardableResult
  func auth() -> URLSessionDataTask? {
    return nil
  }
}

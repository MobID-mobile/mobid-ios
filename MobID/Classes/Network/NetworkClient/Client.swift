//  Created by admin on 23.12.2020.

import Foundation

struct Response<T: Decodable> {
  let result: Result<T, ClientError>
  let request: URLRequest?
}

class Client {

  required init(urlSessionManager: URLSessionManager = URLSessionManager(configuration: URLSessionConfiguration.default),
                queue: DispatchQueue = DispatchQueue(label: "mobID.NetworkClient. " + UUID().uuidString)) {
    self.urlSessionManager = urlSessionManager
    self.queue = queue
  }


  private let urlSessionManager: URLSessionManager
  private let queue: DispatchQueue

  @discardableResult
  func perform<T: Decodable>(_ requestConvertible: URLRequestConvertible,
                             completion: @escaping (Response<T>) -> Void) -> URLSessionDataTask? {
    do {
      let request = try requestConvertible.asURLRequest()
      return urlSessionManager.perform(request: request) { [weak self] response in
        guard let self = self else { return }
        self.queue.async {
          let result: Result<T, ClientError> = response.result
            .flatMap(ifSuccess: self.verifyServerResponse, ifFailure: self.networkErrorToResult)
            .flatMap(ifSuccess: self.parseResult, ifFailure: liftError)

          completion(.init(result: result, request: request))
        }
      }
    } catch {
      completion(.init(result: .failure(.endpointError(error: error)), request: nil))
      return nil
    }
  }

  @discardableResult
  func performURLRequest<T: Decodable>(_ request: URLRequest,
                                       completion: @escaping (Response<T>) -> Void) -> URLSessionDataTask? {
    return urlSessionManager.perform(request: request) { [weak self] response in
      guard let self = self else { return }
      self.queue.async {
        let result: Result<T, ClientError> = response.result
          .flatMap(ifSuccess: self.verifyServerResponse, ifFailure: self.networkErrorToResult)
          .flatMap(ifSuccess: self.parseResult, ifFailure: liftError)

        completion(.init(result: result, request: request))
      }
    }
  }

  func verifyServerResponse(_ response: (data: Data?, urlResponse: HTTPURLResponse)) -> Result<Data?, ClientError> {
    if (200..<300).contains(response.urlResponse.statusCode) {
      return .success(response.0)
    } else {
      return .failure(.serverError(statusCode: response.urlResponse.statusCode))
    }
  }

  func parseResult<T: Decodable>(_ data: Data?) -> Result<T, ClientError> {
    guard let data = data else {
      return .failure(.dataIsEmptyError)
    }

    do {
      let decoder = JSONDecoder()
      let decodedData = try decoder.decode(T.self, from: data)
      return .success(decodedData)
    } catch {
      return .failure(.parsingError(error: error))
    }
  }

  func networkErrorToResult(_ error: URLSessionError) -> Result<Data?, ClientError> {
    return .failure(.networkError(error: error))
  }

  func respononse<T: Codable>(with result: Result<T, ClientError>, request: URLRequest) -> Response<T> {
    return Response(result: result, request: request)
  }
}

// MARK: - Concrete methods
extension Client {

  @discardableResult
  func auth(to conferenceID: String?, completion: @escaping (Response<Auth>) -> Void) -> URLSessionDataTask? {

    return perform(
      EndpointRouter.auth(
        parameters: [
          "conference_id": conferenceID ?? "null",
          "status": VerificationStatus.WAIT_INVITE.rawValue
        ]
      ),
      completion: completion
    )
  }

  @discardableResult
  func verification(completion: @escaping (Response<Verification>) -> Void) -> URLSessionDataTask? {

    return perform(
      EndpointRouter.verification,
      completion: completion
    )
  }

  @discardableResult
  func stopConference(completion: @escaping (Response<ConferenceUpdate>) -> Void) -> URLSessionDataTask? {

    return perform(
      EndpointRouter.stopConference(
        parameters: [
          "verification": EndpointRouter.verificationID,
          "status": VerificationStatus.CONFERENCE_STOP.rawValue
        ]
      ),
      completion: completion
    )
  }

  @discardableResult
  func openConferences(completion: @escaping (Response<OpenConferences>) -> Void) -> URLSessionDataTask? {

    return perform(
      EndpointRouter.openConferences,
      completion: completion
    )
  }

  @discardableResult
  func photo(image: UIImage,
             type: PhotoType,
             completion: @escaping (Response<Photo>) -> Void) -> URLSessionDataTask? {

    let photoEndpoint = EndpointRouter.photo(
      parameters: [
        "type": type.rawValue,
        "verification": EndpointRouter.verificationID
      ]
    )
    
    do {
      let url = try photoEndpoint.asURLRequest().url!
      let multipartRequest = try MultipartRequest.make(
        url: url,
        image: image,
        type: type.rawValue,
        verification: EndpointRouter.verificationID,
        token: EndpointRouter.token
      )

      return performURLRequest(multipartRequest.0, completion: completion)
    } catch {
      completion(.init(result: .failure(.endpointError(error: error)), request: nil))
      return nil
    }
  }
}

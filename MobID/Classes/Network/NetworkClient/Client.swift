//  Created by admin on 23.12.2020.

import Foundation

struct Response<T: Decodable> {
  public let result: Result<T, ClientError>
  public let request: URLRequest?
}

class Client {

  private enum C {
    static let host = "api.mobid.ai"
  }
  required init(urlSessionManager: URLSessionManager = URLSessionManager(configuration: URLSessionConfiguration.default),
                queue: DispatchQueue = DispatchQueue(label: "mobID.NetworkClient. " + UUID().uuidString),
                host: String = C.host) {
    self.urlSessionManager = urlSessionManager
    self.queue = queue
    
    EndpointRouter.host = host
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

  func performUpload<T: Decodable>(request: URLRequest,
                                   form: Data,
                                   completion: @escaping (Response<T>) -> Void) -> URLSessionDataTask? {
    do {
      return urlSessionManager.upload(request: request, form: form) { [weak self] response in
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
  func auth(completion: @escaping (Response<Auth>) -> Void) -> URLSessionDataTask? {

    return perform(
      EndpointRouter.auth(
        parameters: [
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
  func photo(image: UIImage,
             type: PhotoType,
             completion: @escaping (Response<Photo>) -> Void) -> URLSessionDataTask? {

    let photoEndpoint = EndpointRouter.photo(
      parameters: [
        "type": type.rawValue,
//        "file": strBase64,
        "verification": EndpointRouter.id
      ]
    )
    let url = try! photoEndpoint.asURLRequest().url!
    let multipartRequest = try! MultipartRequest.make(
      url: url,
      image: image,
      type: type.rawValue,
      verification: EndpointRouter.id
    )

    return performUpload(request: multipartRequest.0, form: multipartRequest.1, completion: completion)
    //    return performUpload(request: )
//    return perform(
//      photoEndpoint,
//      completion: completion
//    )
  }
}

//  Created by admin on 10.12.2020.

import Foundation
import Alamofire

typealias ResponseType = [String: AnyObject]

class NetworkClient {

  // MARK: - Private
  private enum C {
    static let hostAddress = "https://api.mobid.ai/api/v1/kyc/check/"
    static let assets = "assets/"
    static let pk = "pk"
  }

  private struct Auth: Encodable {
    let username: String
    let password: String
  }

  private struct Photo: Encodable {
    let check: String?
    let image: Data
  }

  private struct Session: Encodable {
    let pk: String?
  }

  // MARK: - Interface
  enum NetworkClientError: Error {
    case parsingError
  }

  enum PhotoType: String {
    case selfie
    case passport
    case photowdoc
  }

  private static var checkID: String?
  private static var token: String = ""

  static func auth(completion: ((Result<ResponseType, Error>) -> Void)?) {
    let urlString = C.hostAddress
    AF.request(
      urlString,
      method: .post,
      parameters: Auth(username: "root", password: "admin123")).responseJSON { response in
        switch response.result {
        case .success(let data):
          if let value = data as? [String: AnyObject] {
            setCheckID(from: value)
            setToken(from: value)
            completion?(.success(value))
          } else {
            completion?(.failure(NetworkClientError.parsingError))
          }
        case .failure(let error):
          completion?(.failure(error))
        }
      }
  }

  static func sendPhoto(_ data: Data,
                        type: PhotoType,
                        completion: ((Result<ResponseType, Error>) -> Void)?) {
    let urlString: String = C.hostAddress + C.assets + type.rawValue
    let headers: Alamofire.HTTPHeaders = [
      "authorization": "Bearer " + token,
      "Content-Type": "application/json"
    ]

    AF.request(
      urlString,
      method: .post,
      parameters: Photo(check: checkID, image: data),
      headers: headers).responseJSON { response in
        switch response.result {
        case .success(let data):
          if let value = data as? [String: AnyObject] {
            print(value)
            completion?(.success(value))
          } else {
            completion?(.failure(NetworkClientError.parsingError))
          }
        case .failure(let error):
          print(error)
          completion?(.failure(error))
        }
      }
  }

  static func getSession(completion: ((Result<ResponseType, Error>) -> Void)?) {
    let urlString: String = C.hostAddress
    let headers: Alamofire.HTTPHeaders = [
      "authorization": "Bearer " + token,
      "Content-Type": "application/json"
    ]

    AF.request(
      urlString,
      method: .get,
      parameters: Session(pk: checkID),
      headers: headers).responseJSON { response in
        switch response.result {
        case .success(let data):
          if let value = data as? [String: AnyObject] {
            completion?(.success(value))
          } else {
            completion?(.failure(NetworkClientError.parsingError))
          }
        case .failure(let error):
          print(error)
          completion?(.failure(error))
        }
      }
  }
}

// MARK: - Private
private extension NetworkClient {
  static func setCheckID(from response: [String: AnyObject]) {
    guard let anyId = response["id"], let id = anyId as? String else {
      return
    }

    checkID = id
  }

  static func setToken(from response: [String: AnyObject]) {
    guard let anyToken = response["token"], let token = anyToken as? String else {
      return
    }

    self.token = token
  }
}

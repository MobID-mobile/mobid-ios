//  Created by admin on 24.12.2020.

import Foundation

class MultipartRequest {

  enum MultipartRequestError: Error {
    case InvalidRequest
    case dataIsEmptyError
  }

  static func make(url: URL, image: UIImage, type: String, verification: String) throws -> (URLRequest, Data) {
//    guard let latitude = story.location.latitude,
//          let longitude = story.location.longitude,
//          let categoryIds = story.categoryIds,
//          let title = story.title,
//          let description = story._description else {
//      throw MultipartRequestError.InvalidRequest
//    }
//
//    let locationString =  """
//        {
//        "latitude": \(latitude.stringValue),
//        "longitude": \(longitude.stringValue)
//        }
//        """

//    let categoryIdsData = try JSONSerialization.data(withJSONObject: categoryIds, options: [])
//
//    guard let categoryIdsString = String(data: categoryIdsData, encoding: .utf8) else {
//      throw MultipartRequestError.InvalidRequest
//    }


//    var queryParams: [String: String] = ["title": title,
//                                         "description": description,
//                                         "authorName": story.authorName,
//                                         "location": locationString,
//                                         "categoryIds": categoryIdsString]
//    if let videoId = story.videoId {
//      queryParams["videoId"] = videoId
//    }

//    if let clientId = clientId {
//      queryParams["clientId"] = clientId.stringValue
//    }

    let boundary = "Boundary-\(UUID().uuidString)"
    var request  = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    let imageName = "hello-\(UUID().uuidString)"

    let dataToUpload = try Self.makeUploadData(
      boundary: boundary,
      parameters:
        [
          "type": type,
          "verification": verification
      ],
      image: image,
      imageKey: "file",
      imageMimeType: "image/jpeg",
      imageFilename: imageName
//      audioURLString: story.audioURL,
//      audioKey: "sdwd",
//      audioMimeType: "audio/x-m4a",
//      audioFilename: audioName
    )

    return (request, dataToUpload)
  }

  static func makeUploadData(boundary: String,
                      parameters: [String: String],
                      image: UIImage,
                      imageKey: String,
                      imageMimeType: String,
                      imageFilename: String) throws -> Data {
    guard let imageData = image.jpegData(compressionQuality: 0.7) else {
      throw MultipartRequestError.dataIsEmptyError
    }

    let body = NSMutableData()

    let boundaryPrefix = "--\(boundary)\r\n"

    for (key, value) in parameters {
      body.appendString(boundaryPrefix)
      body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
      body.appendString("\(value)\r\n")
    }

    body.appendString(boundaryPrefix)
    body.appendString("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"\(imageFilename)\"\r\n")
    body.appendString("Content-Type: \(imageMimeType)\r\n\r\n")
    body.append(imageData)
    body.appendString("\r\n")

    body.appendString("--".appending(boundary.appending("--")))

    return body as Data
  }

  func makeAudioData(audioURLString: String?) -> Data? {
    guard let path = audioURLString,
          let audioData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      return nil
    }

    return audioData
  }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

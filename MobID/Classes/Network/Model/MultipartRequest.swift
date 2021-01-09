//  Created by admin on 24.12.2020.

import Foundation

class MultipartRequest {
  
  enum MultipartRequestError: Error {
    case InvalidRequest
    case dataIsEmptyError
  }
  
  static func make(url: URL, image: UIImage, type: String, verification: String, token: String) throws -> (URLRequest, Data) {
    
    let boundary = "Boundary-\(UUID().uuidString)"
    var request  = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    let imageName = "\(UUID().uuidString).jpeg"
    
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
    )
    
    request.httpBody = dataToUpload
    
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
    
    var body = Data()
    
    let boundaryPrefix = "--\(boundary)\r\n"
    
    for (key, value) in parameters {
      body.appendString(boundaryPrefix)
      body.appendString("Content-Disposition:form-data; name=\"\(key)\"\r\n\r\n")
      body.appendString("\(value)\r\n")
    }
    
    body.appendString(boundaryPrefix)
    body.appendString("Content-Disposition:form-data; name=\"\(imageKey)\"; filename=\"\(imageFilename)\"\r\n")
    body.appendString("Content-Type: \(imageMimeType)\r\n\r\n")
    body.append(imageData)
    body.appendString("\r\n")
    
    body.appendString("--".appending(boundary.appending("--")))
    
    return body
  }
}


extension Data {
  mutating func appendString(_ string: String) {
    let data = string.data(using: .utf8, allowLossyConversion: false)
    append(data!)
  }
}

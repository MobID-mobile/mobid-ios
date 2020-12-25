//  Created by admin on 24.12.2020.

import Foundation

class MultipartRequest {

  enum MultipartRequestError: Error {
    case InvalidRequest
    case dataIsEmptyError
  }

  static func make(url: URL, image: UIImage, type: String, verification: String, token: String) throws -> (URLRequest, Data) {
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
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let imageName = "hello-\(UUID().uuidString).jpeg"

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

    request.httpBody = dataToUpload

    print(String(data: dataToUpload, encoding: .utf8))

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

    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
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
//    body.appendString(strBase64)
//    body.appendString("wAARCADqATkDASIAAhEBAxEB/8QAFwABAQEBAAAAAAAAAAAAAAAAAAECA//EACQQAQEBAAIBBAMBAQEBAAAAAAABESExQQISUXFhgZGxocHw/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAH/xAAWEQEBAQAAAAAAAAAAAAAAAAAAEQH/2gAMAwEAAhEDEQA/AMriLyCKgg1gQwCgs4FTMOdutepjQak+FzMSVqgxZdRdPPIIvH5WzzGdBriphtTeAXg2ZjKA1pqKDUGZca3foBek8gFv8Ie3fKdA1qb8s7hoL6eLVt51FsAnql3Ut1M7AWbflLMDkEMX/F6/YjK/pADFQAUNA6alYagKk72m/j9p4Bq2fDDSYKLNXPNLoHE/NT6RYC31cJxZ3yWVM+aBYi/S2ZgiAsnYJx5D21vPmqrm3PTfpQQwyAC8JZvSKDni41ZrMuUVVl+Uz9w9v/1QWrZsZ5nFPHYH+JZyureQSF5M+fJ0CAfwRAVRBQA1DAWVUayoJUWoDpsxntPsueBV4+VxhdyAtv8AjOLGpIDMLbeGvbF4iozJfr/WukAVABAXAQXEAAASzVAZdO2WNordm+emFl7XcQSNZiFtv0C9w90nhJf4mA1u+GcJFwIyAqL/AOovwgGNfSRqdIrNa29M0gKCAojU9PAMjWXpckEJFNFEAAXEUBABYz6rZ0ureQc9vyt9XxDF2QAXtABcQAs0AZywkvluJbyipifas52DcyxjlZweAO0xri/hc+wZOEKIu6nSyeToVZyWXwvCg53gW81QQ7aTNAn5dGZJPs1UXURQAUEMCXQLZE93PRZ5hPTgNMrbIzKCm52LZwCs+2M8w2g3sjPuZAXb4IsMAUACzVUGM4/K+md6vEXUUyM5PDR0IxYe6ramih0VNBrS4xoqN8Q1BFQk3yqyAsioioAAKgDSJL4/jQIn5igLrPqtOuf6oOaxbMoAltUAhhIoJiiggrPu+AaOIxtAX3JbaAIaLwi4t9X4T3fg2AFtqcrUUarP20zUDAmqoE0WRBZPNVUVEAAAAVAC8kvih2DSKxOdBqs7Z0l0gI0mKAC4AuHE7ZtBriM+744QAAAAABAFsveIttBICyaikvy1+r/Cen5rWQHIBQa4rIDRqSl5qDWqziqgAAAATA7BpGdqXb2C2+J/UgAtRQBSQtkBWb6vhLbQAAAAAEBRAAAAAUbm+GZNdPxAP+ql2Tjwx7/wIgZ8iKvBk+CJoCXii9gaqZ/qqihAAAEVABGkBFUwBftNkZ3QW34QAAABFAQAVAAAAAARVkl8gs/43sk1jL45LvHArepk+E9XTG35oLqsmIKmLAEygKg0y1AFQBUXwgAAAoBC34S3UAAABAVAAAAAABAUQAVABdRQa1PcYyit2z58M8C4ouM2NXpOEGeWtNZUatiAIoAKIoCoAoG4C9MW6dgIoAIAAAAAAACKWAgL0CAAAALiANCKioNLgM1CrLihmTafkt1EF3SZ5ZVUW4mnIKvAi5fhEURVDWVQBRAAAAAAAAQFRVyAyulgAqCKlF8IqLsEgC9mGoC+IusqCrv5ZEUVOk1RuJfwSLOOkGFi4XPCoYYrNiKauosBGi9ICstM1UAAAAAAFQ0VcTBAXUGgIqGoKhKAzRRUQUAwxoSrGRpkQA/qiosOL9oJptMRRVZa0VUqSiChE6BqMgCwqKqIogAIAqKCKgKoogg0lBFuIKgAAAKNRlf2gqsftsEtZWoAAqAACKoMqAAeSoqp39kL2AqLOlE8rEBFQARYALhigrNC9gGmooLp4TweEQFFBFAECgIoAu0ifIAqAAA//9k=")

//    body.appendString("MOCK")

    body.appendString("\r\n")

    body.appendString("--".appending(boundary.appending("--")))

    foobar()
    return body as Data
  }

  static func foobar() {
    let parameters = [
      [
        "key": "type",
        "value": "SELFIE",
        "type": "text"
      ],
      [
        "key": "verification",
        "value": "b123add3-15dc-4dad-9b66-884b1c71cfe5",
        "type": "text"
      ],
      [
        "key": "file",
        "src": "/home/mtw/Pictures/00a97c77-d8e4-413d-87b2-1edddb506e94.jpeg",
        "type": "file"
      ]] as [[String : Any]]
    let boundary = "Boundary-\(UUID().uuidString)"
    var body = ""
    var error: Error? = nil
    for param in parameters {
      if param["disabled"] == nil {
        let paramName = param["key"]!
        body += "--\(boundary)\r\n"
        body += "Content-Disposition:form-data; name=\"\(paramName)\""
        if param["contentType"] != nil {
          body += "\r\nContent-Type: \(param["contentType"] as! String)"
        }
        let paramType = param["type"] as! String
        if paramType == "text" {
          let paramValue = param["value"] as! String
          body += "\r\n\r\n\(paramValue)\r\n"
        } else {
          let paramSrc = param["src"] as! String
//          let fileData = try? NSData(contentsOfFile:paramSrc, options:[]) as Data
//          let fileContent = String(data: fileData, encoding: .utf8)!
          let fileContent = "MOCK"
          body += "; filename=\"\(paramSrc)\"\r\n"
            + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
        }
      }
    }
    body += "--\(boundary)--\r\n";
    let postData = body.data(using: .utf8)
    var request = URLRequest(url: URL(string: "https://api.mobid.ai/api/v1.1/verifications/b123add3-15dc-4dad-9b66-884b1c71cfe5/images/")!,timeoutInterval: Double.infinity)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MTAxOTE0MjEsInZlcmlmaWNhdGlvbl9pZCI6IjhlYzQ4YTA4LWJlYjEtNGJkOC05Mzg4LTY0M2EzY2Y1OTBhYSJ9.TnYBsTclxDSUxZj4mioX8kRKYrkRsUiKClW2IrQgG2o", forHTTPHeaderField: "Authorization")
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = postData

    print(String(data: postData!, encoding: .utf8))
    print("here")
  }
}


extension Data {
  mutating func appendString(_ string: String) {
    let data = string.data(using: .utf8, allowLossyConversion: false)
    append(data!)
  }
}

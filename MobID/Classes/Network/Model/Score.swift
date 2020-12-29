//  Created by admin on 23.12.2020.

import Foundation

// MARK: - Score
struct Score: Codable {
  let scoreID: String
  let document, facialMatch, liveness: String?
  let isOcrRecognized: Bool?

  enum CodingKeys: String, CodingKey {
    case scoreID = "score_id"
    case document
    case facialMatch = "facial_match"
    case liveness
    case isOcrRecognized = "is_ocr_recognized"
  }
}

//  Created by admin on 24.12.2020.

import Foundation

// MARK: - Photo
struct Photo: Codable {
  let imageID, type, status: String
  let file: String
  let verification, createdAt: String
  let image400X400: String?
  
  enum CodingKeys: String, CodingKey {
    case imageID = "image_id"
    case type, status, file, verification
    case createdAt = "created_at"
    case image400X400 = "image_400x400"
  }
}

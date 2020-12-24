//  Created by admin on 23.12.2020.

import Foundation

struct Verification: Codable {
  let verificationID: String
  let status: VerificationStatus
  let isActive, isVerifiedByAgent: Bool?
  let score: Score
  let documentData, createdAt, updatedAt: String
  let images: [String]
  let conference: Conference?
  
  enum CodingKeys: String, CodingKey {
    case verificationID = "verification_id"
    case status
    case isActive = "is_active"
    case isVerifiedByAgent = "is_verifyed_by_agent"
    case score
    case documentData = "document_data"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case images, conference
  }
}

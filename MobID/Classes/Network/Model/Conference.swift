//  Created by admin on 24.12.2020.

import Foundation
// MARK: - Conference
struct Conference: Codable {
  let conferenceID, jitsiHost, jitsiRoom: String
  let createdAt: String
  let verification: VerificationDetails

  enum CodingKeys: String, CodingKey {
    case conferenceID = "conference_id"
    case verification
    case jitsiHost = "jitsi_host"
    case jitsiRoom = "jitsi_room"
    case createdAt = "created_at"
  }
}

// MARK: - VerificationDetails
struct VerificationDetails: Codable {
  let verificationID, status: String

  enum CodingKeys: String, CodingKey {
    case verificationID = "verification_id"
    case status
  }
}

//  Created by admin on 01.04.2021.

import Foundation

// MARK: - OpenConference
public struct OpenConference: Codable {
  public let conferenceID, agentEmail, status, createdAt: String

  enum CodingKeys: String, CodingKey {
    case conferenceID = "conference_id"
    case agentEmail = "agent_email"
    case status
    case createdAt = "created_at"
  }
}

public typealias OpenConferences = [OpenConference]


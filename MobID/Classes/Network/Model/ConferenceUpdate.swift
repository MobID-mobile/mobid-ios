//  Created by admin on 30.03.2021.

import Foundation

// MARK: - ConferenceUpdate
struct ConferenceUpdate: Codable {
    let conferenceID: String
    let verification: VerificationDetails
    let status, jitsiHost, jitsiRoom, createdAt: String

    enum CodingKeys: String, CodingKey {
        case conferenceID = "conference_id"
        case verification, status
        case jitsiHost = "jitsi_host"
        case jitsiRoom = "jitsi_room"
        case createdAt = "created_at"
    }
}

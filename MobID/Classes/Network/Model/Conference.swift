//  Created by admin on 24.12.2020.

import Foundation
// MARK: - Conference
struct Conference: Codable {
    let conferenceID, verification, jitsiHost, jitsiRoom: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case conferenceID = "conference_id"
        case verification
        case jitsiHost = "jitsi_host"
        case jitsiRoom = "jitsi_room"
        case createdAt = "created_at"
    }
}

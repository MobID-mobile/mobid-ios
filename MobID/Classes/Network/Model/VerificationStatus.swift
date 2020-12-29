//  Created by admin on 23.12.2020.

import Foundation

enum VerificationStatus: String, Codable {
  case WAIT_INVITE
  case CONFERENCE_START
  case SELFIE_START
  case PASSPORT_PHOTO_START
  case SELFIE_WITH_PASSPORT_PHOTO_START
  case CONFERENCE_STOPPED
}

//  Created by admin on 23.12.2020.

import Foundation

enum VerificationStatus: String, Codable {
  case WAIT_INVITE
  case CONFERENCE_START
  case SELFIE_1_START
  case SELFIE_2_START
  case DOCUMENTS_START
  case SELFIE_WITH_DOCUMENTS_START
  case CONFERENCE_STOP
}

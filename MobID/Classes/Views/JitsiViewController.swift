//  Created by admin on 04.12.2020.

import UIKit
import JitsiMeetSDK

class JitsiViewController: UIViewController, JitsiMeetViewDelegate {

  // MARK: - Private
  private var jitsiView: JitsiMeetView {
    return view as! JitsiMeetView
  }

  // MARK: - Interface
  private(set) var connected: Bool = false
  var leaveCompletion: (() -> Void)?

  func leave() {
    jitsiView.leave()
  }

  func join(serverURL: URL, room: String) {
    let jitsiMeetConferenceOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
      builder.serverURL = serverURL
      builder.audioOnly = false
      builder.room = room
    }

    jitsiView.join(jitsiMeetConferenceOptions)
  }

  // MARK: - Override
  override func viewDidLoad() {
    super.viewDidLoad()
    jitsiView.delegate = self
  }

  override func loadView() {
    view = JitsiMeetView()
  }
}

// MARK: - JitsiMeetViewDelegate
extension JitsiViewController {
  func conferenceJoined(_ data: [AnyHashable : Any]!) {
    connected = true
  }

  func conferenceTerminated(_ data: [AnyHashable : Any]!) {
    connected = false
    leaveCompletion?()
  }
}

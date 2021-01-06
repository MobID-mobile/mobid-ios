//  Created by admin on 04.12.2020.

import UIKit
import JitsiMeetSDK

class JitsiViewController: UIViewController, JitsiMeetViewDelegate {

  // MARK: - Nested
  private enum C {
    static let host: URL = URL(string: "https://jitsi.mobid.ai/")!
  }

  // MARK: - Private
  private var jitsiView: JitsiMeetView {
    return view as! JitsiMeetView
  }

  private var leaveCompletion: (() -> Void)?
  private var connected: Bool = false

  // MARK: - Interface
  func leave(completion: (() -> Void)?) {
    leaveCompletion = completion
    if connected == false {
      leaveCompletion?()
      leaveCompletion = nil
    } else {
      jitsiView.leave()
    }
  }

  func join(room: String?) {
    let jitsiMeetConferenceOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
      builder.serverURL = C.host
      builder.audioOnly = false
//      builder.audioMuted = true
//      builder.videoMuted = true
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

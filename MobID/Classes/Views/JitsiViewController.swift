//  Created by admin on 04.12.2020.

import UIKit
import JitsiMeetSDK

class JitsiViewController: UIViewController, JitsiMeetViewDelegate {

  // MARK: - Nested
  enum JitsiViewControllerError: Error {
    case unableToBuildHostURL
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

  func join(hostName: String?, room: String?) throws {
    guard let hostName = hostName, let room = room else {
      throw JitsiViewControllerError.unableToBuildHostURL
    }

    let host = "https://" + hostName
    guard let serverURL: URL = URL(string: host) else {
      throw JitsiViewControllerError.unableToBuildHostURL
    }

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

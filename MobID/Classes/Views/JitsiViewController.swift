//
//  JitsiViewController.swift
//  MobID
//
//  Created by admin on 04.12.2020.
//

import UIKit
import JitsiMeet

class JitsiViewController: UIViewController, JitsiMeetViewDelegate {

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

  func joint() {
    let jitsiMeetConferenceOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
      builder.serverURL = URL(string: "https://jitsi.mobid.ai/")!
      builder.audioOnly = false
//      builder.audioMuted = true
//      builder.videoMuted = true
      builder.room = "test"
    }

    jitsiView.join(jitsiMeetConferenceOptions)
  }

  // MARK: - Override
  override func viewDidLoad() {
    super.viewDidLoad()
    jitsiView.delegate = self
  }

  // MARK: - JitsiMeetViewDelegate
  func conferenceJoined(_ data: [AnyHashable : Any]!) {
    connected = true
  }

  func conferenceTerminated(_ data: [AnyHashable : Any]!) {
    connected = false
    leaveCompletion?()
  }
}

// MARK: - Make
extension JitsiViewController {
  static func make() -> JitsiViewController {
    let bundle = Bundle(for: JitsiViewController.self)
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    return storyboard.instantiateInitialViewController() as! JitsiViewController
  }
}


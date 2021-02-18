//  Created by admin on 06.12.2020.

import UIKit
import ALCameraViewController

class VerificationViewController: UIViewController {

  // MARK: - Private
  private let networkClient = Client()
  private let conferenceStatusRequester = ConferenceStatusRequester()
  private var status: VerificationStatus = .WAIT_INVITE
  private var jitsiRoom: String?
  private var jitsiHost: String?
  private lazy var jitsiMeetViewController = JitsiViewController()

  // MARK: - Override
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addJitsiMeetView()

    setupVerificationUpdateTimer()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stopVerification()
  }
  
  // MARK: - Subviews management
  private func addJitsiMeetView() {
    add(child: jitsiMeetViewController)

    jitsiMeetViewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      jitsiMeetViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
      jitsiMeetViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      jitsiMeetViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      jitsiMeetViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
    ])
  }
}

// MARK: - Logic
private extension VerificationViewController {

  func startJitsi() {
    do {
      try jitsiMeetViewController.join(hostName: jitsiHost, room: jitsiRoom)
    } catch {
      showErrorAlert()
    }
  }

  func setupVerificationUpdateTimer() {
    conferenceStatusRequester.start { [weak self] response in
      guard let self = self else { return }

      switch response.result {
      case let .success(verification):
        guard self.status != verification.status else {
          return
        }
        self.status = verification.status
        self.process(model: verification)
      case let .failure(error):
        print(error)
        break
      }
    }
  }

  func process(model: Verification) {
    switch status {
    case .CONFERENCE_START:
      jitsiRoom = model.conference?.jitsiRoom
      jitsiHost = model.conference?.jitsiHost
      startJitsi()
    case .CONFERENCE_STOP:
      finishVerification(model: model)
    case .WAIT_INVITE,
         .SELFIE_1_START,
         .SELFIE_2_START,
         .DOCUMENTS_START,
         .SELFIE_WITH_DOCUMENTS_START:
      break
    }
  }

  func stopVerification() {
    conferenceStatusRequester.stop()
    jitsiMeetViewController.leave(completion: nil)
  }

  func finishVerification(model: Verification) {
    stopVerification()

    let dValue = model.score?.document
    let fValue = model.score?.facialMatch
    let lValue = model.score?.liveness

    navigationController?.pushViewController(
      EndViewController(
        dValue: dValue.flatMap { Float($0) },
        fValue: fValue.flatMap { Float($0) },
        lValue: lValue.flatMap { Float($0) }
      ),
      animated: true)
  }
}

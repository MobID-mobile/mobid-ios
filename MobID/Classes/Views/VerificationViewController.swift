//  Created by admin on 06.12.2020.

import UIKit

class VerificationViewController: UIViewController {

  // MARK: - Private
  private let networkService = NetworkService()
  private var status: VerificationStatus = .WAIT_INVITE
  private lazy var jitsiMeetViewController = JitsiViewController()

  // MARK: - Override
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addJitsiMeetView()

    startVerificationStatusMonitoring()
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

    jitsiMeetViewController.leaveCompletion = { [networkService] in
      networkService.stopConference { _ in }
    }
  }
}

// MARK: - Logic
private extension VerificationViewController {

  func startJitsi(hostName: String?, room: String?) {
    guard let hostName = hostName, let room = room else {
      return
    }
    let host = "https://" + hostName
    guard let serverURL = URL(string: host) else {
      return
    }

    jitsiMeetViewController.join(serverURL: serverURL, room: room)
  }

  func startVerificationStatusMonitoring() {
    networkService.startVerificationStatusMonitoring { [weak self] response in
      DispatchQueue.main.async {
        guard let self = self else { return }

        switch response.result {
        case let .success(verification):
          guard self.status != verification.status else {
            return
          }
          self.status = verification.status
          self.process(model: verification)
        case .failure:
          break
        }
      }
    }
  }

  func process(model: Verification) {
    switch status {
    case .CONFERENCE_START:
      startJitsi(hostName: model.conference?.jitsiHost, room: model.conference?.jitsiRoom)
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
    jitsiMeetViewController.leave()
    networkService.stopVerificationStatusMonitoring()
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

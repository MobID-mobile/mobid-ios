//  Created by admin on 06.12.2020.

import UIKit

public class VerificationViewController: UIViewController {

  // MARK: - Public
  public var conferenceID: String?
  
  // MARK: - Private
  private let networkService = NetworkService()
  private var status: VerificationStatus = .WAIT_INVITE
  private lazy var jitsiMeetViewController = JitsiViewController()

  private lazy var spinner: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .gray)
    view.hidesWhenStopped = true

    return view
  }()

  private lazy var waitingForAgentLabel: UILabel = {
    let label = UILabel()
    label.text = "Очікуємо підключення оператора"
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    label.isHidden = true
    return label
  }()

  // MARK: - Override
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    addJitsiMeetView()
    addSubviews()

    connectToVerification()
  }

  public override func viewDidDisappear(_ animated: Bool) {
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

    jitsiMeetViewController.view.isHidden = true

    jitsiMeetViewController.leaveCompletion = { [networkService] in
      networkService.stopConference { _ in }
    }
  }

  private func addSubviews() {

    spinner.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(spinner)

    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
    ])

    view.addSubview(waitingForAgentLabel)

    NSLayoutConstraint.activate([
      waitingForAgentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      waitingForAgentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
    ])

    waitingForAgentLabel.isHidden = true
  }

  private func showHideWaitingForConnection(show: Bool) {
    switch show {
    case true:
      spinner.startAnimating()
      waitingForAgentLabel.isHidden = false
    case false:
      spinner.stopAnimating()
      waitingForAgentLabel.isHidden = true
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

    jitsiMeetViewController.view.isHidden = false
    jitsiMeetViewController.join(serverURL: serverURL, room: room)
  }

  func connectToVerification() {
    spinner.startAnimating()
    networkService.connect(to: conferenceID) { [weak self] response in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.spinner.stopAnimating()
        switch response.result {
        case .success:
          self.startVerificationStatusMonitoring()
        case .failure:
          break
        }
      }
    }
  }

  func startVerificationStatusMonitoring() {
    showHideWaitingForConnection(show: true)
    networkService.startVerificationStatusMonitoring { [weak self] response in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.showHideWaitingForConnection(show: false)

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
      stopVerification()
    case .WAIT_INVITE,
         .SELFIE_1_START,
         .SELFIE_2_START,
         .DOCUMENTS_START,
         .SELFIE_WITH_DOCUMENTS_START:
      break
    }
  }

  func stopVerification() {
    jitsiMeetViewController.view.isHidden = true
    jitsiMeetViewController.leave()
    networkService.stopVerificationStatusMonitoring()
  }
}

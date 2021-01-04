//  Created by admin on 06.12.2020.

import UIKit
import ALCameraViewController


class VerificationViewController: UIViewController {

  // MARK: - Private
  private let networkClient = Client()
  private var conferenceCompletionPollingTimer: Timer?
  private var status: VerificationStatus = .WAIT_INVITE
  private var room: String?

  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.brandColor, for: .normal)
    button.backgroundColor = .white
    button.setTitle("", for: .normal)
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

    button.sizeToFit()
    button.translatesAutoresizingMaskIntoConstraints = false
    return button

  }()

  private lazy var jitsiMeetViewController = JitsiViewController()
  private var progressLabel: UILabel = UILabel()

  // MARK: - Override
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addJitsiMeetView()
    assSubviews()

    setupVerificationUpdateTimer()
  }

  // MARK: - Init/deinit
  deinit {
    conferenceCompletionPollingTimer?.invalidate()
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
  
  private func assSubviews() {
    view.addSubview(actionButton)
    actionButton.isHidden = true
    
    NSLayoutConstraint.activate([
      actionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
      actionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
      actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor , constant: -24)
    ])

    progressLabel.text = "Відправляємо фото..."
    progressLabel.sizeToFit()
    progressLabel.textColor = UIColor.brandColor
    progressLabel.translatesAutoresizingMaskIntoConstraints = false
    progressLabel.isHidden = true
    view.addSubview(progressLabel)

    NSLayoutConstraint.activate([
      progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      progressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
    ])
  }
  
  // MARK: - Actions

  @objc private func didTapButton() {
    jitsiMeetViewController.leave { [weak self] in
      guard let self = self else { return }

      var type: PhotoType?

      switch self.status {
      case .SELFIE_START:
        type = .SELFIE
      case .PASSPORT_PHOTO_START:
        type = .PASSPORT
      case .SELFIE_WITH_PASSPORT_PHOTO_START:
        type = .SELFIE_WITH_PASSPORT
      default:
        break
      }

      guard let photoType = type else {
        return
      }

      self.presentALCameraView(for: photoType)
    }
  }
}

// MARK: - Logic
private extension VerificationViewController {

  func startJitsi() {
    jitsiMeetViewController.join(room: room)
  }

  func processCameraOutput(image: UIImage?, photoType: PhotoType) {
    
    guard let image = image else {
      self.showErrorAlert()
      startJitsi()
      return
    }

    progressLabel.isHidden = false
    view.bringSubviewToFront(progressLabel)

    networkClient.photo(image: image, type: photoType) { [weak self] response in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch response.result {
        case let .success(photo):
          print(photo)
        case let .failure(error):
          print(error.localizedDescription)
          self.showErrorAlert()
        }
        self.progressLabel.isHidden = true
        self.startJitsi()
      }
    }
  }

  func setupVerificationUpdateTimer() {
    conferenceCompletionPollingTimer = Timer.scheduledTimer(
      withTimeInterval: 3,
      repeats: true,
      block: { [weak self] timer in
        self?.networkClient.verification { response in
          DispatchQueue.main.async {
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
      })
  }

  func process(model: Verification) {
    switch status {
    case .WAIT_INVITE:
      break
    case .CONFERENCE_START:
      room = model.conference?.jitsiRoom
      startJitsi()
    case .SELFIE_START:
      break
    case .PASSPORT_PHOTO_START:
      break
    case .SELFIE_WITH_PASSPORT_PHOTO_START:
      break
    case .CONFERENCE_STOPPED:
      stopConference(model: model)
    }

    changeActionButtonState()
  }

  func stopConference(model: Verification) {

    let dValue = model.score?.document
    let fValue = model.score?.facialMatch
    let lValue = model.score?.liveness

    conferenceCompletionPollingTimer?.invalidate()
    self.jitsiMeetViewController.leave(completion: nil)
    self.navigationController?.pushViewController(
      EndViewController(
        dValue: dValue.flatMap { Float($0) },
        fValue: fValue.flatMap { Float($0) },
        lValue: lValue.flatMap { Float($0) }
      ),
      animated: true)
  }

  func changeActionButtonState() {

    switch status {
    case .WAIT_INVITE:
      actionButton.isHidden = true
      actionButton.setTitle("", for: .normal)
    case .CONFERENCE_START:
      actionButton.setTitle("", for: .normal)
      actionButton.isHidden = true
    case .SELFIE_START:
      actionButton.setTitle("Зробити селфі", for: .normal)
      actionButton.isHidden = false
    case .PASSPORT_PHOTO_START:
      actionButton.setTitle("Зробити фото паспорту", for: .normal)
      actionButton.isHidden = false
    case .SELFIE_WITH_PASSPORT_PHOTO_START:
      actionButton.setTitle("Зробити селфі з паспортом", for: .normal)
      actionButton.isHidden = false
    case .CONFERENCE_STOPPED:
      actionButton.isHidden = true
      actionButton.setTitle("", for: .normal)
    }
  }
}

// MARK: - Navigation
private extension VerificationViewController {
  func presentALCameraView(for photoType: PhotoType) {
    DispatchQueue.main.async {

      let cameraCroppingParameters = CroppingParameters(
        isEnabled: false,
        allowResizing: false,
        allowMoving: false,
        minimumSize: CGSize(width: 100, height: 100)
      )

      let cameraViewCompletion: CameraViewCompletion = { [weak self] image, asset in
        guard let self = self else { return }
        self.dismiss(animated: true) {
          self.processCameraOutput(image: image, photoType: photoType)
        }
      }
      let cameraViewController: UIViewController
      #if targetEnvironment(simulator)
      cameraViewController = CameraViewController.imagePickerViewController(croppingParameters: cameraCroppingParameters, completion: cameraViewCompletion)
      #else
      cameraViewController = CameraViewController(croppingParameters: cameraCroppingParameters, completion: cameraViewCompletion)
      #endif

      if #available(iOS 13.0, *) {
        cameraViewController.isModalInPresentation = true
      }
      self.present(cameraViewController, animated: true, completion: nil)
    }
  }
}

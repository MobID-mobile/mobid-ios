//  Created by admin on 06.12.2020.

import UIKit
import ALCameraViewController


class VerificationViewController: UIViewController {

  // MARK: - Nested
//  enum Status {
//    case waiting
//    case started(room: String)
//    case selfie
//    case passport
//    case selfieAndPassport
//  }

  // MARK: - Private
  private let networkClient = Client()
  private var conferenceCompletionPollingTimer: Timer?
  private var status: VerificationStatus?
  private var room: String?

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
    let selfieButton = UIButton(type: .system)
    selfieButton.setTitleColor(UIColor.brandColor, for: .normal)
    selfieButton.backgroundColor = .white
    selfieButton.setTitle("Зробити селфі", for: .normal)
    selfieButton.addTarget(self, action: #selector(didTapSelfieButton), for: .touchUpInside)
    selfieButton.sizeToFit()
    selfieButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(selfieButton)
    
    NSLayoutConstraint.activate([
      selfieButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      selfieButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
    ])

    let idButton = UIButton(type: .system)
    idButton.setTitleColor(UIColor.brandColor, for: .normal)
    idButton.backgroundColor = .white
    idButton.setTitle("Зробити фото паспорту", for: .normal)
    idButton.addTarget(self, action: #selector(didTapIdButton), for: .touchUpInside)
    idButton.sizeToFit()
    idButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(idButton)

    NSLayoutConstraint.activate([
      idButton.topAnchor.constraint(equalTo: selfieButton.bottomAnchor, constant: 16),
      idButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
    ])

    let selfieWithIdButton = UIButton(type: .system)
    selfieWithIdButton.setTitleColor(UIColor.brandColor, for: .normal)
    selfieWithIdButton.backgroundColor = .white
    selfieWithIdButton.setTitle("Зробити селфі з паспортом", for: .normal)
    selfieWithIdButton.addTarget(self, action: #selector(didTapSelfieWithIdButton), for: .touchUpInside)
    selfieWithIdButton.sizeToFit()
    selfieWithIdButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(selfieWithIdButton)

    NSLayoutConstraint.activate([
      selfieWithIdButton.topAnchor.constraint(equalTo: idButton.bottomAnchor, constant: 16),
      selfieWithIdButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
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
  @objc private func didTapSelfieButton() {
    jitsiMeetViewController.leave { [weak self] in
      self?.presentALCameraView(for: .SELFIE)
    }
  }

  @objc private func didTapIdButton() {
    jitsiMeetViewController.leave { [weak self] in
      self?.presentALCameraView(for: .PASSPORT)
    }
  }

  @objc private func didTapSelfieWithIdButton() {
    jitsiMeetViewController.leave { [weak self] in
      self?.presentALCameraView(for: .SELFIE_WITH_PASSPORT)
    }
  }
}

// MARK: - Logic
private extension VerificationViewController {

  func startJitsi() {
    jitsiMeetViewController.join(room: room)
  }

  func processCameraOutput(image: UIImage?, photoType: PhotoType) {
    
    guard let image = image, let imageData = image.pngData() else {
      self.showErrorAlert()
      startJitsi()
      return
    }

    progressLabel.isHidden = false
    view.bringSubviewToFront(progressLabel)

//    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
    networkClient.photo(image: image, type: photoType) { [weak self] response in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch response.result {
        case .success:
          print("here")
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
              self.process(model: verification)
            case .failure:
              break
            }
          }
        }
      })
  }

  func process(model: Verification) {
    status = model.status
    switch (model.status) {
    case (.WAIT_INVITE):
      break
    case (.CONFERENCE_START):
      status = model.status
      room = model.conference?.jitsiRoom
      startJitsi()
    case (.SELFIE_START):
      break
    case (.PASSPORT_PHOTO_START):
      break
    case (.SELFIE_WITH_PASSPORT_PHOTO_START):
      break
    }

    //            timer.invalidate()
    //            self.jitsiMeetViewController.leave(completion: nil)
    //            self.navigationController?.pushViewController(
    //              EndViewController(
    //                dValue: self.convertToFloat(dictionary["document_score"]),
    //                fValue: self.convertToFloat(dictionary["facial_match"]),
    //                lValue: self.convertToFloat(dictionary["liveness_score"])
    //              ),
    //              animated: true)
  }

  func convertToFloat(_ value: AnyObject?) -> Float {
    guard let string = value as? String, let float = Float(string) else {
      return 0.0
    }
    return float
  }
}

// MARK: - Navigation
private extension VerificationViewController {
  func presentALCameraView(for photoType: PhotoType) {
    DispatchQueue.main.async {
      let cameraViewController = CameraViewController(
        croppingParameters:
          .init(
            isEnabled: false,
            allowResizing: false,
            allowMoving: false,
            minimumSize: CGSize(width: 100, height: 100))) { [weak self] image, asset in
        guard let self = self else { return }
        self.dismiss(animated: true) {
          self.processCameraOutput(image: image, photoType: photoType)
        }
      }

      if #available(iOS 13.0, *) {
        cameraViewController.isModalInPresentation = true
      }
      self.present(cameraViewController, animated: true, completion: nil)
    }
  }
}

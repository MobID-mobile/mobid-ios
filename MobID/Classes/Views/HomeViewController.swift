//  Created by admin on 06.12.2020.

import UIKit
import ALCameraViewController

class HomeViewController: UIViewController {

  // MARK: - Private
  private lazy var jitsiMeetViewController = JitsiViewController.make()
  private var conferenceCompletionPollingTimer: Timer?

  private lazy var progressLabel: UILabel = {
    return UILabel()
  }()

//  private lazy var spinner: UIActivityIndicatorView = {
//    let view = UIActivityIndicatorView(style: .large)
//    view.hidesWhenStopped = true
//
//    return view
//  }()

  // MARK: - Override
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addJitsiMeetView()
    assSubviews()

    jitsiMeetViewController.joint()

    setupConferenceCompletionPolling()
  }

  deinit {
    conferenceCompletionPollingTimer?.invalidate()
  }
  
  // MARK: - Private
  private func addJitsiMeetView() {
    add(child: jitsiMeetViewController)
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

//    spinner.translatesAutoresizingMaskIntoConstraints = false
//    view.addSubview(spinner)
//
//    NSLayoutConstraint.activate([
//      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//      spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
//    ])

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
  
  private func presentALCameraView(for photoType: NetworkClient.PhotoType) {
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

  private func processCameraOutput(image: UIImage?, photoType: NetworkClient.PhotoType) {
    guard let image = image, let imageData = image.pngData() else {
      jitsiMeetViewController.joint()
      return
    }

    progressLabel.isHidden = false
    view.bringSubviewToFront(progressLabel)
    NetworkClient.sendPhoto(imageData, type: photoType) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch result {
        case .success:
          break
        case .failure:
          self.showErrorAlert()
        }
        self.progressLabel.isHidden = true
        self.jitsiMeetViewController.joint()
      }
    }
  }
  
  // MARK: - Actions
  @objc func didTapSelfieButton() {
    jitsiMeetViewController.leave { [weak self] in
      self?.presentALCameraView(for: .selfie)
    }
  }

  @objc func didTapIdButton() {
    jitsiMeetViewController.leave { [weak self] in
      self?.presentALCameraView(for: .passport)
    }
  }

  @objc func didTapSelfieWithIdButton() {
    jitsiMeetViewController.leave { [weak self] in
      self?.presentALCameraView(for: .photowdoc)
    }
  }
}

private extension HomeViewController {
  func setupConferenceCompletionPolling() {
    conferenceCompletionPollingTimer = Timer.scheduledTimer(
      withTimeInterval: 3,
      repeats: true,
      block: { [weak self] timer in
      NetworkClient.getSession { (result) in
        guard let self = self else { return }
        switch result {
        case .success(let dictionary):
          if let conferenceCompleted = dictionary["conference_verification_completed"] as? Bool,
             conferenceCompleted == true {
            timer.invalidate()
            self.jitsiMeetViewController.leave(completion: nil)

            self.navigationController?.pushViewController(
              ByeViewController(
                dValue: self.convertToFloat(dictionary["document_score"]),
                fValue: self.convertToFloat(dictionary["facial_match"]),
                lValue: self.convertToFloat(dictionary["liveness_score"])
              ),
              animated: true)
          }
        case .failure:
          break
        }
      }
    })
  }

  func convertToFloat(_ value: AnyObject?) -> Float {
    guard let string = value as? String, let float = Float(string) else {
      return 0.0
    }
    return float
  }
}

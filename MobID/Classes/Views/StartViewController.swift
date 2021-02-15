//  Created by admin on 09.12.2020.

import UIKit

public class StartViewController: UIViewController {

  // MARK: - Override
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addSubviews()
  }

  // MARK: - Private
  private let networkClient = Client()
  private let conferenceStatusRequester = ConferenceStatusRequester()

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

  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Почати відеодзвінок", for: .normal)
    button.setTitleColor(UIColor.brandColor, for: .normal)
    button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
    button.sizeToFit()
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  // MARK: - Subviews management
  private func addSubviews() {

    let imageView = UIImageView(image: UIImage.logo)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)

    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 54),
    ])

    view.addSubview(actionButton)

    NSLayoutConstraint.activate([
      actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      actionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
    ])

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

  // MARK: - Actions
  @objc private func didTapStartButton() {
    spinner.startAnimating()
    networkClient.auth { [weak self] response in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.spinner.stopAnimating()
        switch response.result {
        case let .success(auth):

          EndpointRouter.token = auth.token
          EndpointRouter.id = auth.verificationID

          self.startMonitoringStatus()
        case .failure:
          self.showErrorAlert()
        }
      }
    }
  }
}

// MARK: - Private
private extension StartViewController {
  func startMonitoringStatus() {
    showHideWaitingForConnection(show: true)
    conferenceStatusRequester.start { [weak self] response in
      guard let self = self else { return }
      
      switch response.result {
      case let .success(verification) where verification.status == .WAIT_INVITE:
        break
      case .success:
        self.showHideWaitingForConnection(show: false)
        self.conferenceStatusRequester.stop()
        self.push()
      case .failure:
        self.showHideWaitingForConnection(show: false)
        self.conferenceStatusRequester.stop()
        self.showErrorAlert()
      }
    }
  }

  func showHideWaitingForConnection(show: Bool) {
    switch show {
    case true:
      spinner.startAnimating()
      actionButton.isHidden = true
      waitingForAgentLabel.isHidden = false
    case false:
      spinner.stopAnimating()
      actionButton.isHidden = false
      waitingForAgentLabel.isHidden = true
    }
  }
}

// MARK: - Navigation
private extension StartViewController {
  func push() {
    guard let navController = navigationController else {
      assertionFailure("StartViewController should be in a navigation stack")
      return
    }

    navController.pushViewController(VerificationViewController(), animated: true)
  }
}

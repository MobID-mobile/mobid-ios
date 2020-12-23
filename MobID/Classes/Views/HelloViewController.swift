//  Created by admin on 09.12.2020.

import UIKit

public class HelloViewController: UIViewController {

  // MARK: - Override
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addSubviews()
  }

  // MARK: - Private
  private let networkClient = Client()

  private lazy var spinner: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .gray)
    view.hidesWhenStopped = true

    return view
  }()

  private func addSubviews() {

    let imageView = UIImageView(image: UIImage.logo)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)

    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
      imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
      imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
    ])

    let button = UIButton(type: .system)
    button.setTitle("Почати відеодзвінок", for: .normal)
    button.setTitleColor(UIColor.brandColor, for: .normal)
    button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
    button.sizeToFit()
    button.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(button)

    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
    ])

    spinner.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(spinner)
    
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
    ])
  }

  // MARK: - Actions
  @objc private func didTapStartButton() {
    spinner.startAnimating()
    networkClient.auth { [weak self] response in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.spinner.stopAnimating()
        switch response.result {
        case let .success(verification):

          EndpointRouter.token = verification.token
          EndpointRouter.id = verification.verificationID

          self.push()
        case .failure(_):
          self.showErrorAlert()
        }
      }
    }
  }

  private func push() {
    guard let navController = navigationController else {
      assertionFailure("HelloViewController should be in a navigation stack")
      return
    }
    navController.pushViewController(HomeViewController(), animated: true)
  }
}

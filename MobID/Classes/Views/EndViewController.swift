//  Created by admin on 09.12.2020.

import UIKit

class EndViewController: UIViewController {

  // MARK: - Init
  init(dValue: Float, fValue: Float, lValue: Float) {
    self.dValue = dValue
    self.fValue = fValue
    self.lValue = lValue

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Override
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addSubviews()

    vDocumentScoreLabel.text = dValue.description + "%"
    vFacialMatchLabel.text = fValue.description + "%"
    vLivenessScoreLabel.text = lValue.description + "%"
  }

  // MARK: - Private
  private let dValue, fValue, lValue: Float

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    stackView.spacing = 24
    stackView.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0)
    stackView.isLayoutMarginsRelativeArrangement = true
    return stackView
  }()

  private lazy var documentScoreLabel: UILabel = {
    let label = UILabel()
    label.text = "Document score"
    label.textAlignment = .left
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var facialMatchLabel: UILabel = {
    let label = UILabel()
    label.text = "Facial match"
    label.textAlignment = .left
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var livenessScoreLabel: UILabel = {
    let label = UILabel()
    label.text = "Liveness score"
    label.textAlignment = .left
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var vStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    stackView.spacing = 24
    stackView.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0)
    stackView.isLayoutMarginsRelativeArrangement = true
    return stackView
  }()

  private lazy var vDocumentScoreLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.textAlignment = .right
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var vFacialMatchLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.textAlignment = .right
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var vLivenessScoreLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.textAlignment = .right
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
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

    let label = UILabel()
    label.text = "Дякуємо за ваш час"
    label.sizeToFit()
    label.textColor = UIColor.brandColor
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
    ])

    /*
    let documentScoreLabel = UILabel()
    documentScoreLabel.text = "Document score"
    documentScoreLabel.sizeToFit()
    documentScoreLabel.textColor = UIColor.brandColor
    documentScoreLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      documentScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      documentScoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
    ])

    let facialMatchLabel = UILabel()
    facialMatchLabel.text = "Facial match"
    facialMatchLabel.sizeToFit()
    facialMatchLabel.textColor = UIColor.brandColor
    facialMatchLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(facialMatchLabel)

    NSLayoutConstraint.activate([
      facialMatchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      facialMatchLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
    ])

    let livenessScoreLabel = UILabel()
    livenessScoreLabel.text = "Liveness score"
    livenessScoreLabel.sizeToFit()
    livenessScoreLabel.textColor = UIColor.brandColor
    livenessScoreLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(livenessScoreLabel)

    NSLayoutConstraint.activate([
      livenessScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      livenessScoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
    ])
    */

    view.addSubview(stackView)
    stackView.addArrangedSubview(documentScoreLabel)
    stackView.addArrangedSubview(facialMatchLabel)
    stackView.addArrangedSubview(livenessScoreLabel)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 24),
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
      stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150),
    ])

    view.addSubview(vStackView)
    vStackView.addArrangedSubview(vDocumentScoreLabel)
    vStackView.addArrangedSubview(vFacialMatchLabel)
    vStackView.addArrangedSubview(vLivenessScoreLabel)

    NSLayoutConstraint.activate([
      vStackView.topAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 24),
      vStackView.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 8),
      vStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
      vStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150)
    ])
  }
}

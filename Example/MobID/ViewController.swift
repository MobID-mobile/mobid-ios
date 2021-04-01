//
//  ViewController.swift
//  MobID
//
//  Created by AleksandrPavliuk on 12/22/2020.
//  Copyright (c) 2020 AleksandrPavliuk. All rights reserved.
//

import UIKit
import MobID

class ViewController: UIViewController {

  private let tableView = UITableView()
  private var conferences: [String] = []
  private enum C {
    static let cellReuseIdentifier = "theCellReuseIdentifier"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    MobID.delegate = self

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: C.cellReuseIdentifier)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 145),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -145)
    ])

    loadOpenConferences()
  }

  private func loadOpenConferences() {
    MobID.getOpenConferences() { [weak self] result in
      switch result {
      case let .success(openConferences):
        DispatchQueue.main.async {
          self?.conferences = openConferences.map { $0.conferenceID }
          self?.tableView.reloadData()
        }
      case .failure(_):
        break
      }
    }
  }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conferences.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: C.cellReuseIdentifier, for: indexPath)
    cell.textLabel?.text = conferences[indexPath.row]
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let id = conferences[indexPath.row]
    let startViewController = StartViewController()
    startViewController.conferenceID = id
    navigationController?.pushViewController(startViewController, animated: true)
  }
}


extension ViewController: MobIDDelegate {
  func verificationStatus(_ status: VerificationStatus) {
    print(status)
  }

  func errorOccurred(_ error: ClientError) {
    print(error)
  }
}

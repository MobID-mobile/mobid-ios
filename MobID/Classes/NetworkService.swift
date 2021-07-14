//  Created by admin on 04.01.2021.

import Foundation

class NetworkService {

  // MARK: - Private
  private var conferenceCompletionPollingTimer: Timer?
  private let networkClient = Client()

  // MARK: - Init/deinit
  deinit {
    stopVerificationStatusMonitoring()
  }

  // MARK: - Interface
  func openConferences(completion: @escaping (Response<OpenConferences>) -> Void) {
    networkClient.openConferences(completion: completion)
  }

  func tokenAuth(callback: @escaping (ClientError?) -> Void) {
    networkClient.tokenAuth {
      switch $0.result {
      case let .success(tokenAuth):
        MobIDConfig.token = tokenAuth.token
        callback(nil)
      case let .failure(error):
        MobID.delegate?.errorOccurred(error)
        callback(error)
      }
    }
  }

  func stopConference(callback: @escaping (Response<ConferenceUpdate>) -> Void) {
    networkClient.stopConference() { result in
      callback(result)
    }
  }

  func connect(to conferenceID: String?, callback: @escaping (Response<Connect>) -> Void) {
    networkClient.connect(to: conferenceID) {
      switch $0.result {
      case let .success(connect):
        MobIDConfig.verificationID = connect.verificationID

      case let .failure(error):
        MobID.delegate?.errorOccurred(error)
      }
      callback($0)
    }
  }

  // MARK: - Interface
  func startVerificationStatusMonitoring(callback: @escaping (Response<Verification>) -> Void) {
    conferenceCompletionPollingTimer?.invalidate()
    conferenceCompletionPollingTimer = Timer.scheduledTimer(
      withTimeInterval: 3,
      repeats: true,
      block: { [weak self] timer in
        self?.networkClient.verification {
          switch $0.result {
          case let .success(verification):
            MobID.delegate?.verificationStatus(verification.status)
          case let .failure(error):
            MobID.delegate?.errorOccurred(error)
          }
          callback($0)
        }
      })
  }

  func stopVerificationStatusMonitoring() {
    conferenceCompletionPollingTimer?.invalidate()
  }
}

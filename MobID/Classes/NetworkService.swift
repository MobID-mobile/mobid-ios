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

  func auth(callback: @escaping (Response<Auth>) -> Void) {
    networkClient.auth {
      switch $0.result {
      case let .success(auth):

        EndpointRouter.token = auth.token
        EndpointRouter.id = auth.verificationID

      case let .failure(error):
        MobID.delegate?.errorOccurred(error)
      }
      callback($0)
    }
  }

  // MARK: - Interface
  func startVerificationStatusMonitoring(callback: @escaping (Response<Verification>) -> Void) {
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

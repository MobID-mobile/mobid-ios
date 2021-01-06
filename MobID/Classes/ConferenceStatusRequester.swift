//  Created by admin on 04.01.2021.

import Foundation

class ConferenceStatusRequester {

  // MARK: - Private
  private var conferenceCompletionPollingTimer: Timer?
  private let networkClient = Client()

  // MARK: - Init/deinit

  deinit {
    stop()
  }

  // MARK: - Interface
  func start(callback: @escaping (Response<Verification>) -> Void) {
    conferenceCompletionPollingTimer = Timer.scheduledTimer(
      withTimeInterval: 3,
      repeats: true,
      block: { [weak self] timer in
        self?.networkClient.verification { response in
          DispatchQueue.main.async {
            callback(response)
          }
        }
      })
  }

  func stop() {
    conferenceCompletionPollingTimer?.invalidate()
  }
}

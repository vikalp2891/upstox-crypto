//
//  NetworkService.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//
import Network

class NetworkMonitor: @unchecked Sendable {
  
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "NetworkMonitorQueue")
  
  private(set) var isConnected: Bool = false {
    didSet {
      print("Network status changed: \(isConnected ? "Connected" : "Disconnected")")
      didChange?(isConnected)
    }
  }
  
  var didChange: ((Bool) -> Void)?
  
  init(didChange: ((Bool) -> Void)? = nil) {
    self.didChange = didChange
    startMonitoring()
  }
  
  private func startMonitoring() {
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else { return }
      self.isConnected = path.status == .satisfied
    }
    
    // Start monitoring the network status on the background queue
    monitor.start(queue: queue)
  }
  
  func stopMonitoring() {
    monitor.cancel()
  }
}

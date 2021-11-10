//
//  NetworkMonitor.swift
//  Pies
//
//  Created by Robert Harrison on 11/10/21.
//

import Foundation
import Network

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let networkMonitor = NWPathMonitor()
    //private var isNetworkOnline = false
    private let networkMonitorQueue = DispatchQueue(label: "com.fresh.Pies.NetworkMonitor")

    var isOnline: Bool {
        return networkMonitor.currentPath.status == .satisfied
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    func start() {
        networkMonitor.start(queue: networkMonitorQueue)
    }

}

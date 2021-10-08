//
//  APIQueues.swift
//  Analytics
//
//  Created by Nathan Larson on 3/5/19.
//  Copyright © 2019 Nathan Larson. All rights reserved.
//

import Foundation

class APIQueues {
    static let shared = APIQueues()
    
    lazy var defaultQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
}

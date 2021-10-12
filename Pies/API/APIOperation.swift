//
//  APIOperation.swift
//  Pies
//
//  Created by Nathan Larson on 3/5/19.
//  Copyright © 2019 Nathan Larson. All rights reserved.
//

import Foundation

final class APIOperation: Operation {
    
    typealias OperationComplete = (Data?) -> ()
    
    var request: URLRequest
    var completeAction: OperationComplete
    
    init(request: URLRequest, completed: @escaping OperationComplete) {
        self.request = request
        self.completeAction = completed
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                PiesLogger.shared.logError(message: error.localizedDescription)
                self.completeAction(nil)
                return
            }
            
            guard response != nil else {
                PiesLogger.shared.logError(message: "No API Response")
                self.completeAction(nil)
                return
            }
            
            if let data = data {
                self.completeAction(data)
            } else {
                self.completeAction(nil)
            }
            
        }
        
        task.resume()
        
    }
    
}


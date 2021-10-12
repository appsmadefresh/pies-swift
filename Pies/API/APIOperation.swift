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
    
    var operationExecuting: Bool = true
    var operationFinished: Bool = false
    
    init(request: URLRequest, completed: @escaping OperationComplete) {
        self.request = request
        self.completeAction = completed
    }
    
    override var isExecuting: Bool {
        return operationExecuting
    }
    
    override var isFinished: Bool {
        return operationFinished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    @objc func completeOperation() -> Void {
        willChangeValue(forKey: "isFinished")
        willChangeValue(forKey: "isExecuting")
        operationExecuting = false
        operationFinished = true
        didChangeValue(forKey: "isFinished")
        didChangeValue(forKey: "isExecuting")
    }
    
    override func main() {
        if self.isCancelled {
            willChangeValue(forKey: "isFinished")
            operationFinished = true
            didChangeValue(forKey: "isFinished")
            return
        }
        
        willChangeValue(forKey: "isExecuting")
        operationExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let err = error {
                print(err.localizedDescription)
                self.completeAction(nil)
                self.completeOperation()
                return
            }
            
            guard response != nil else {
                PiesLogger.shared.logError(message: "No API Response")
                self.completeAction(nil)
                self.completeOperation()
                return
            }
            
            if let data = data {
                self.completeAction(data)
            } else {
                self.completeAction(nil)
            }
            
            self.completeOperation()
        }
        
        task.resume()
        
    }
    
}


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
            cacheEvent(forRequest: request)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                PiesLogger.shared.logDebug(message: error.localizedDescription)
                self.cacheEvent(forRequest: self.request)
                self.completeAction(nil)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                PiesLogger.shared.logDebug(message: "No API Response")
                self.completeAction(nil)
                return
            }
            
            switch response.statusCode {
            case 200:
                if let data = data {
                    self.completeAction(data)
                } else {
                    PiesLogger.shared.logDebug(message: "Response data is nil")
                    self.completeAction(nil)
                }
                
            case 400:
                PiesLogger.shared.logError(message: "Invalid Request")
                self.completeAction(nil)
                
            case 401:
                PiesLogger.shared.logError(message: "Unauthorized Request")
                self.completeAction(nil)
                
            case 403:
                PiesLogger.shared.logError(message: "Forbidden")
                self.completeAction(nil)
                
            default:
                self.cacheEvent(forRequest: self.request)
                self.completeAction(nil)
            }
            
        }
        
        task.resume()
        
    }
    
    func cacheEvent(forRequest request: URLRequest) {
        
        do {
            guard let data = request.httpBody else { return }
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let event = json[APIField.event()] as? [String: Any] {
                EventCache.putBackEvent(event)
            }
            
        } catch let error as NSError {
            PiesLogger.shared.logError(message: "Failed to cache event: \(error.localizedDescription)")
        }
        
    }
    
}


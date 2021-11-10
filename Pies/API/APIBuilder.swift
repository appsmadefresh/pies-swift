//
//  APIBuilder.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import Foundation

final class APIBuilder {
    
    static let trackEventURL = "https://us-central1-pies-d01b8.cloudfunctions.net/trackEvent"
    static let trackEventEmulatorURL = "http://localhost:5001/pies-d01b8/us-central1/trackEvent"
        
    static func request(forEvent event: [String: Any],
                                appId: String,
                                apiKey: String,
                                useEmulator: Bool = false) -> URLRequest? {
        
        let urlString = useEmulator ? APIBuilder.trackEventEmulatorURL : APIBuilder.trackEventURL
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            APIField.appId(): appId,
            APIField.apiKey(): apiKey,
            APIField.event(): event
        ]
       
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            PiesLogger.shared.logError(message: error.localizedDescription)
            return nil
        }
        
        guard jsonData != nil else { return nil }
        
        request.httpBody = jsonData
        
        return request
    }
    
}

//
//  APIBuilder.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import Foundation

final class APIBuilder {
    
    static let trackEventURL = "https://us-central1-pies-d01b8.cloudfunctions.net/trackEvent"
    
    static func requestForNewInstall(appId: String, apiKey: String, deviceId: String) -> URLRequest? {
        return APIBuilder.request(forEventType: .newInstall, appId: appId, apiKey: apiKey, deviceId: deviceId)
    }
    
    static func requestForSessionStart(appId: String, apiKey: String, deviceId: String) -> URLRequest? {
        return APIBuilder.request(forEventType: .sessionStart, appId: appId, apiKey: apiKey, deviceId: deviceId)
    }
    
    static func requestForInAppPurchase(appId: String, apiKey: String, deviceId: String, purchaseInfo: [String: Any]) -> URLRequest? {
        return APIBuilder.request(forEventType: .inAppPurchase, appId: appId, apiKey: apiKey, deviceId: deviceId, userInfo: purchaseInfo)
    }
    
    private static func request(forEventType eventType: EventType, appId: String, apiKey: String, deviceId: String, userInfo: [String: Any]? = nil) -> URLRequest? {
        let url = URL(string: APIBuilder.trackEventURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var event: [String: Any] = [
            APIField.timestamp(): Date().timeIntervalSince1970,
            APIField.eventType(): eventType.rawValue,
            APIField.deviceId(): deviceId
        ]
        
        if let userInfo = userInfo {
            for (key, value) in userInfo {
                event[key] = value
            }
        }
        
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
//
//  String+Version.swift
//  Pies
//
//  Created by Robert Harrison on 12/8/21.
//

import UIKit

extension String {
    
    static var applicationVersion: String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let version = infoDictionary["CFBundleShortVersionString"] as? String,
              let build = infoDictionary["CFBundleVersion"] as? String else {
            return ""
        }
        return "\(version) (\(build))"
    }
    
    static var frameworkVersion: String {
        guard let infoDictionary = Bundle(for: Pies.self).infoDictionary,
              let version = infoDictionary["CFBundleShortVersionString"] as? String,
              let build = infoDictionary["CFBundleVersion"] as? String else {
            return ""
        }
        return "\(version) (\(build))"
    }
    
    static var osVersion: String {
        return UIDevice.current.systemVersion
    }
}

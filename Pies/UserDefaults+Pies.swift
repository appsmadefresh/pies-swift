//
//  UserDefaults+Pies.swift
//  Pies
//
//  Created by Robert Harrison on 11/2/21.
//

import Foundation

extension UserDefaults {
    static var pies: UserDefaults {
        return UserDefaults(suiteName: "group.pies.framework")!
    }
}

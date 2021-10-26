//
//  PriceFormatter.swift
//  Pies
//
//  Created by Robert Harrison on 10/26/21.
//

import Foundation
import StoreKit

extension SKProduct {
    
    var formattedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self.price) ?? ""
    }
    
}

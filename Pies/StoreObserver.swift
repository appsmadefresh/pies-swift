//
//  StoreObserver.swift
//  Pies
//
//  Created by Robert Harrison on 10/26/21.
//

import Foundation
import StoreKit

final class StoreObserver: NSObject {
    
    private var products = [String: SKProduct]() // key = productIdentifier
    private var productRequests = [SKProductsRequest]()
    
    private var pendingTransactionsToTrack = [SKPaymentTransaction]()
    
    private var userDefaults: UserDefaults!
    private var useEmulator = false
    
    private var eventEmitter: EventEmitter
    
    private var isSandboxOrSimulator: Bool {
        let isSandbox = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

        #if targetEnvironment(simulator)
            let isSimulator = true
        #else
            let isSimulator = false
        #endif

        return isSandbox || isSimulator
    }
    
    init(userDefaults: UserDefaults, useEmulator: Bool = false) {
        self.userDefaults = userDefaults
        self.useEmulator = useEmulator
        self.eventEmitter = EventEmitter(userDefaults: userDefaults, useEmulator: useEmulator)
    }
    
    private func requestPrices(forTransactions transactions: [SKPaymentTransaction]) {
        
        let productIdentifiers: [String] = transactions.compactMap { transaction in
            if transaction.transactionState == .purchased {
                return transaction.payment.productIdentifier
            } else {
                return nil
            }
        }
        
        guard !productIdentifiers.isEmpty else { return }
        
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = self
        productRequests.append(productRequest)
        productRequest.start()
    }
    
    private func processPendingTransactionsToTrack() {
        var transaction: SKPaymentTransaction? = pendingTransactionsToTrack.removeFirst()
        while transaction != nil {
            trackPurchaseEvent(forTransaction: transaction!)
            if !pendingTransactionsToTrack.isEmpty {
                transaction = pendingTransactionsToTrack.removeFirst()
            } else {
                transaction = nil
            }
        }
    }
    
    private func trackPurchaseEvent(forTransaction transaction: SKPaymentTransaction) {
        
        var purchaseInfo: [String: Any] = [
            "productIdentifier": transaction.payment.productIdentifier,
            "quantity": transaction.payment.quantity,
            "transactionState": transaction.transactionState.rawValue
        ]
        
        if let transactionIdentifier = transaction.transactionIdentifier {
            purchaseInfo["transactionIdentifier"] = transactionIdentifier
        }
        
        if let transactionDate = transaction.transactionDate {
            purchaseInfo["transactionDate"] = transactionDate.timeIntervalSince1970
        }
        
        if #available(iOS 12.2, *) {
            if let paymentDiscount = transaction.payment.paymentDiscount {
                purchaseInfo["paymentDiscountIdentifier"] = paymentDiscount.identifier
            }
        }
        
        
        if let product = products[transaction.payment.productIdentifier] {
            
            purchaseInfo["localizedTitle"] = product.localizedTitle
            
            purchaseInfo["price"] = product.formattedPrice
            
            if let currencyCode = product.priceLocale.currencyCode {
                purchaseInfo["currencyCode"] = currencyCode
            }
            
            if let currencySymbol = product.priceLocale.currencySymbol {
                purchaseInfo["currencySymbol"] = currencySymbol
            }
            
            if let regionCode = product.priceLocale.regionCode {
                purchaseInfo["region"] = regionCode
            }
            
            if let languageCode = product.priceLocale.languageCode {
                purchaseInfo["language"] = languageCode
            }
            
            if let subscriptionGroupIdentifier = product.subscriptionGroupIdentifier, let subscriptionPeriod = product.subscriptionPeriod {
                purchaseInfo["isSubscription"] = true
                purchaseInfo["subscriptionGroupIdentifier"] = subscriptionGroupIdentifier
                purchaseInfo["subscriptionPeriodNumberOfUnits"] = subscriptionPeriod.numberOfUnits
                purchaseInfo["subscriptionPeriodUnit"] = subscriptionPeriod.unit.rawValue
            } else {
                purchaseInfo["isSubscription"] = false
            }
        }
        
        if transaction.payment.simulatesAskToBuyInSandbox {
            purchaseInfo["isSandbox"] = true
        }
        
        eventEmitter.sendEvent(ofType: .inAppPurchase, userInfo: purchaseInfo)
    }
    
}

// MARK: - SKPaymentTransactionObserver

extension StoreObserver: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
        guard !isSandboxOrSimulator else { return }
        
        for transaction in transactions {
            guard transaction.transactionState == .purchased else { continue }
            self.pendingTransactionsToTrack.append(transaction)
        }
        
        requestPrices(forTransactions: transactions)
    }
}

// MARK: - SKProductsRequestDelegate

extension StoreObserver: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        guard !isSandboxOrSimulator else { return }
        
        DispatchQueue.main.async {
            for product in response.products {
                self.products[product.productIdentifier] = product
            }
            self.processPendingTransactionsToTrack()
        }
        
    }
}

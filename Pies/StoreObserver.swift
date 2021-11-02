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
    
    private var keychain: KeychainSwift
    private var useEmulator = false
    
    init(keychain: KeychainSwift, useEmulator: Bool = false) {
        self.keychain = keychain
        self.useEmulator = useEmulator
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
        
        if let paymentDiscount = transaction.payment.paymentDiscount {
            purchaseInfo["paymentDiscountIdentifier"] = paymentDiscount.identifier
        }
        
        if let product = products[transaction.payment.productIdentifier] {
            
            purchaseInfo["localizedTitle"] = product.localizedTitle
            
            purchaseInfo["price"] = product.formattedPrice
            
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
        
        guard let appId = keychain.get(KeychainKey.appId),
              let apiKey = keychain.get(KeychainKey.apiKey),
              let deviceId = keychain.get(KeychainKey.deviceId) else {
            return
        }
        
        guard let request =  APIBuilder.requestForInAppPurchase(appId: appId, apiKey: apiKey, deviceId: deviceId, purchaseInfo: purchaseInfo, useEmulator: useEmulator) else { return }
        
        let operation = APIOperation(request: request) { _ in }
        APIQueues.shared.defaultQueue.addOperation(operation)
    }
    
}

// MARK: - SKPaymentTransactionObserver

extension StoreObserver: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
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
        DispatchQueue.main.async {
            for product in response.products {
                self.products[product.productIdentifier] = product
            }
            self.processPendingTransactionsToTrack()
        }
        
    }
}

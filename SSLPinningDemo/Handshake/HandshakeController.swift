//
//  HandshakeController.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation
import DynamicSSLPin_TA

public class HandshakeController: NSObject {
    public var handshakeListener: HandshakeListener?
    internal var certStore: CertStore? = nil
    
    public init(_ serviceURL: String, _ pubKey: String) {
        
        guard let url = URL(string: serviceURL) else {
            self.handshakeListener?.onResult(HandshakeResult.INVALID_URL)
            return
        }
        
        // Set update interval to two minutes
        // Set expiration Threshold to 5 minutes
        let configuration = CertStoreConfig(serviceURL: url, pubKey: pubKey, updateInterval: 0.5*60, expirationThreshold: 2*60)
        certStore = CertStore.integrateCertStore(configuration: configuration)
    }
    
    public func renewFingerprint() {
        
        // To reset data store every startup
        // DO NOT USE FOR PROD
//        certStore?.resetData()
        
        certStore?.update { (result, error) in
            switch result {
            case .emptyStore:
                self.handshakeListener?.onResult(HandshakeResult.EMPTY_STORE)
            case .invalidData:
                self.handshakeListener?.onResult(HandshakeResult.INVALID_SIGNATURE)
            case .invalidSignature:
                self.handshakeListener?.onResult(HandshakeResult.INVALID_DATA)
            case .networkError:
                self.handshakeListener?.onResult(HandshakeResult.NETWORK_ERROR)
            case .ok:
                self.handshakeListener?.onResult(HandshakeResult.OK)
            }
        }
    }
}

//
//  HandshakeController.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation
import DynamicSSLPin

public class HandshakeController: NSObject {
    public var handshakeListener: HandshakeListener?
    
    public func renewFingerprint(_ pubKey: String, _ serviceURL: String) {
        var certStore: CertStore? = nil
        
        guard let url = URL(string: serviceURL) else {
            self.handshakeListener?.onResult(HandshakeResult.INVALID_URL)
            return
        }
        
        let configuration = CertStoreConfig(serviceURL: url, pubKey: pubKey)
        certStore = CertStore.integrateCertStore(configuration: configuration)
        
        // To reset data store every startup
        // DO NOT USE FOR PROD
        certStore?.resetData()
        
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

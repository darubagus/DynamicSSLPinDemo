//
//  HandshakeListener.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation

public protocol HandshakeListener: NSObject {
    func onResult(_ handshake: HandshakeResult)
}

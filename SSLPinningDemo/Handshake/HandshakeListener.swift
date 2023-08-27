//
//  HandshakeListener.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation

public protocol HandshakeListener {
    
    func onResult(_ result: HandshakeResult)
}

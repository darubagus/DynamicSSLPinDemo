//
//  HandshakeResult.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation

public enum HandshakeResult: Int {
    case OK = 0
    case EMPTY_STORE = 1
    case INVALID_URL = 2
    case INVALID_SIGNATURE = 3
    case INVALID_DATA = 4
}

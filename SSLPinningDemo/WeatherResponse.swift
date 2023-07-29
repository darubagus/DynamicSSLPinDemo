//
//  WeatherResponse.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 07/07/23.
//

import Foundation

struct WeatherResponse: Decodable {
    var main: Main
}

struct Main: Decodable {
    var tempMin: Double
    var tempMax: Double
}

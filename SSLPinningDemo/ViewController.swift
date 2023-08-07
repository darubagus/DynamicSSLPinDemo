//
//  ViewController.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import UIKit
import SwiftUI
import DynamicSSLPin

class ViewController: UIViewController {

    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet var updateFingerprintLabel: UILabel!
    @IBOutlet weak var pinningSwitch: UISwitch!
    
    internal let serviceURL: String! = Bundle.main.infoDictionary!["SERVICE_URL"] as? String
    internal let publicKey = Bundle.main.infoDictionary!["PUBLIC_KEY"] as! String
    
    public var switchIsOn: Bool = true
    private var handShake = HandshakeController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    fileprivate func printData() {
        print(serviceURL ?? "nothing")
    }
    
    @IBAction func onFingerprintUpdate(_ trigger: UIButton){
        handShake.renewFingerprint(publicKey, serviceURL)
    }
    
    @IBAction func onGetWeatherData(_ trigger: UIButton) {
        getWeatherData(switchIsOn: switchIsOn)
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            switchIsOn = true
        } else {
            switchIsOn = false
        }
    }
    
    func onResult(_ result: HandshakeResult) {
        switch result {
        case .OK: print("Everything is alright")
        case .EMPTY_STORE: print("Store is empty")
        case .NETWORK_ERROR: print("Network Error, failed communication")
        case .INVALID_DATA: print("Data did not pass signature validation")
        case .INVALID_SIGNATURE: print("Data did not pass signature validation")
        case .INVALID_URL: print("URL invalid or does not exist")
        }
    }
    
    public func getWeatherData(switchIsOn: Bool) {
        
        var url = URL.init(string: "https://api.openweathermap.org/data/2.5/weather")
        
        let queryItems = [
            URLQueryItem.init(name: "lat", value: "-6.2944"),
            URLQueryItem.init(name: "lon", value: "106.7857"),
            URLQueryItem.init(name: "units", value: "metric"),
            URLQueryItem.init(name: "appid", value: "cc3f0108e08711cb126c71d1c83a8aaf"),
        ]
        
        if #available(iOS 16.0, *) {
            url?.append(queryItems: queryItems)
        } else {
            // Fallback on earlier versions
            var components = URLComponents.init(url: url!, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            url = components?.url
        }
        Debug.message("\(switchIsOn)")
        let restAPI = RestAPI(isPinning: switchIsOn)
        
        restAPI.request(url: url, expecting: WeatherResponse.self) { [weak self] data, error in
            
            if let error {
                let alert = UIAlertController.init(title: error.localizedDescription, message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel))
                DispatchQueue.main.async {
                    self?.present(alert, animated: true)
                }
                print(error.localizedDescription)
                return
            }
            
            if let data {
                DispatchQueue.main.async {
                    self?.minTempLabel.text = "\(data.main.tempMin)"
                    self?.maxTempLabel.text = "\(data.main.tempMax)"
                }
            }
        }
    }
    
}


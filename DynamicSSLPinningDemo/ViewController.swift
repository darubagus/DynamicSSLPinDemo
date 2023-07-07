//
//  ViewController.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet var updateFingerprintLabel: UILabel!
    
    var service_url: String! = Bundle.main.infoDictionary!["SERVICE_URL"] as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData()
        // Do any additional setup after loading the view.
    }

    fileprivate func printData() {
        print(service_url ?? "nothing")
    }
    
    fileprivate func getWeatherData() {
        
        var url = URL.init(string: service_url)
        
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
        
        RestAPI.common.request(url: url, expecting: WeatherResponse.self) { [weak self] data, error in
            
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


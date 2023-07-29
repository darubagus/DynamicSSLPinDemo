//
//  RESTApi.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 07/07/23.
//

import Foundation

class RestAPI: NSObject {
    static let common = RestAPI()
    
    var session: URLSession!
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.ephemeral
        
        session = URLSession.init(configuration: configuration)
    }
    
    func request<T: Decodable>(url: URL?, expecting: T.Type, completion: @escaping (_ data: T?, _ error: Error?)-> ()) {
        
        guard let url else {
            print("Can't form URL")
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            
            if let error {
                if error.localizedDescription == "cancelled" {
                    completion(nil, NSError.init(domain: "", code: -999, userInfo: [NSLocalizedDescriptionKey:"SSL Pinning Failed"]))
                    return
                }
                completion(nil, error)
                return
            }
            
            guard let data else {
                completion(nil, NSError.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Something went wrong"]))
                print("something went wrong")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(T.self, from: data)
                completion(response, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
        
    }
}

//
//  RESTApi.swift
//  DynamicSSLPinningDemo
//
//  Created by Daru Bagus Dananjaya on 07/07/23.
//

import Foundation
import DynamicSSLPin_TA

class RestAPI: NSObject {
//    static let common = RestAPI()
    
    var session: URLSession!
    
    public init(isPinning: Bool) {
        super.init()
        let configuration = URLSessionConfiguration.ephemeral
        
        let url = URL(string: (Bundle.main.infoDictionary!["SERVICE_URL"] as? String)!)
        
        if isPinning {
            let certStoreConfiguration = CertStoreConfig(serviceURL: url!, pubKey: Bundle.main.infoDictionary!["PUBLIC_KEY"] as! String)
            let certStore = CertStore.integrateCertStore(configuration: certStoreConfiguration)
            
            let sessionDelegate = SessionDelegate { (challenge, callback) in
                let validationResult = certStore.validate(challenge: challenge)
                switch validationResult {
                case .trusted:
                    callback(.performDefaultHandling, nil)
                case .untrusted, .empty:
                    callback(.cancelAuthenticationChallenge, nil)
                }
            }
            
            Debug.message("Pinning on")

            session = URLSession.init(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
        } else {
            Debug.message("Pinning off")
            session = URLSession.init(configuration: configuration, delegate: nil, delegateQueue: nil)
        }
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

class SessionDelegate: NSObject, URLSessionDelegate {
    
    var onChallenge: (_ challenge: URLAuthenticationChallenge, _ completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
    
    init(onChallenge: @escaping (_ challenge: URLAuthenticationChallenge, _ completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void) {
        self.onChallenge = onChallenge
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.onChallenge(challenge, completionHandler)
    }
}

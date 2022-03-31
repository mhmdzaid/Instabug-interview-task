//
//  ViewController.swift
//  InstabugInterview
//
//  Created by Yousef Hamza on 1/13/21.
//

import UIKit
import InstabugNetworkClient

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let group = DispatchGroup()
      
        printAllRecords()
        print("------------------------------")
        
        group.enter()

        guard let url4 = URL(string: "https://api.agify.io/?name=bella") else {
            return
        }
        
        NetworkClient.shared.post(url4, payload: self.getParamsData()) { _ in
            group.leave()
        }
        
        group.enter()

        guard let url = URL(string: "https://assets-es-sit1.dxlpreprod.local.vodafone.es/mves/contentnew_ios.json") else {
            return
        }

        NetworkClient.shared.get(url) { _ in
            group.leave()
        }
       
        group.enter()

        guard let url2 = URL(string: "https://api.coindesk.com/v2/bpi/currentprice.json") else {
            return
        }

        NetworkClient.shared.get(url2) { _ in
            group.leave()
        }
        
        
        group.enter()

        guard let url3 = URL(string: "https://archive.org/metadata/TheAdventuresOfTomSawyer_201303") else {
            return
        }

        NetworkClient.shared.get(url3) { _ in
            group.leave()
        }
        
        
        group.notify(queue: .main) {
            self.printAllRecords()
        }
    }
    
    func printAllRecords() {
        _ = NetworkClient.shared.allNetworkRequests().map({ record in
            let request = record.request
            let response = record.response
            
            print("--------------- Request ------------")
            print("url: \(String(describing: request?.url))")
            print("method: \(String(describing: request?.method) )")
            print("payload: \(String(describing: request?.payloadBody) )")
            
            print("--------------- Response ------------")
            print("statusCode: \(String(describing: response?.statusCode))")
            print("errorCode : \(String(describing: response?.errorCode) )")
            print("payload: \(String(describing: response?.payloadBody) )")
            print("errorDomain: \(String(describing: response?.errorDomain) )")
            
        })
    }
    
    
    func getParamsData() -> Data? {
        do {
            let params: [String: Any] = ["product": "liquid",
                                         "count": 3]
            return  try JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed)
            
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
}

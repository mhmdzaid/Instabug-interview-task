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
        
    }
    
    
    @IBAction func sendGet(_ sender: UIButton) {
        
        guard let url = URL(string: "https://httpbin.org/get") else {
            return
        }
        
        NetworkClient.shared.get(url) { data in
            print(data)
        }
    }
    
    @IBAction func sendPost(_ sender: UIButton) {
        guard let url4 = URL(string: "https://httpbin.org/post") else {
            return
        }
        
        NetworkClient.shared.post(url4, payload: self.getParamsData()) { data in
            print(data)
        }
    }
    
    @IBAction func sendPut(_ sender: UIButton) {
        guard let url4 = URL(string: "https://httpbin.org/put") else {
            return
        }
        
        NetworkClient.shared.put(url4, payload: self.getParamsData()) { data in
            print(data)
        }
    }
    
    @IBAction func sendDelete(_ sender: UIButton) {
        guard let url = URL(string: "https://httpbin.org/delete") else {
            return
        }
        NetworkClient.shared.delete(url) { data in
            print(data)
        }
    }
    
    @IBAction func printSavedRecords(_ sender: UIButton) {
        let records = NetworkClient.shared.allNetworkRequests()
        _ = records.map({ record in
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
            print("timeStamp:\(String(describing: record.creationDate))")
        })
        
        print(records.getFirstRecord()?.request?.url ?? "")
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

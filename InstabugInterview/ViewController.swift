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
        guard let url = URL(string: "https://assets-es-sit1.dxlpreprod.local.vodafone.es/mves/contentnew_ios.json") else {
            return
        }
        
        NetworkClient.shared.delete(url) { data in
            print(data)
        }
        
        guard let url2 = URL(string: "https://api.coindesk.com/v2/bpi/currentprice.json") else {
            return
        }
       
        NetworkClient.shared.get(url2) { data in
            print(data)
        }
        
        guard let url3 = URL(string: "https://archive.org/metadata/TheAdventuresOfTomSawyer_201303") else {
            return
        }
        
        NetworkClient.shared.get(url3) { data in
            print(data)
        }
        
        guard let url4 = URL(string: "https://api.agify.io/?name=bella") else {
            return
        }
        
        NetworkClient.shared.get(url4) { data in
            print(data)
        }
        
        NetworkClient.shared.allNetworkRequests().map({print($0.request?.payloadBody ?? "")})
        
    }


}


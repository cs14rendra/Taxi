//
//  ViewController.swift
//  Taxi
//
//  Created by surendra kumar on 11/23/17.
//  Copyright © 2017 surendra kumar. All rights reserved.
//


import UIKit
import UberRides
import CoreLocation
import Foundation
import OAuthSwift

let clientID = "_2-sGt68alcZwmZegdUlphXew-HQNVaS"
let sereverToken = "4yH7FvfOd3gyYKksLA3d3_Q5HdKDDwp9G35we5cZ"

class ViewController: UIViewController {
    
    var  oath : OAuth2Swift?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ =  TokenManager.fetchToken(identifier: "my") {
            let vc = UberVC()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginas(_ sender: Any) {
        self.uberLogin()
    }
    
    func uberLogin(){
        oath = OAuth2Swift(consumerKey: "_2-sGt68alcZwmZegdUlphXew-HQNVaS", consumerSecret: "ZSVqMGSzqS8rAPP7aikVqDlsATUqhZbo5PJu9dsT", authorizeUrl: "https://login.uber.com/oauth/v2/authorize", accessTokenUrl: "https://login.uber.com/oauth/v2/token", responseType: "code")
        if #available(iOS 9.0, *) {
            oath?.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oath!)
        } else {
            // Fallback on earlier versions
        }
        oath!.authorize(withCallbackURL: "com.weza.Taxi://oauth/consumer", scope: "request+profile+all_trips+request_receipt+ride_widgets+places+history_lite+history", state: "UBER", success: { (credential, response, parameters) in
            let tokenS = AccessToken(tokenString: credential.oauthToken)
            if TokenManager.save(accessToken: tokenS, tokenIdentifier: "my"){
                print("saved")
            }else{
                print("not saved")
            }
           
        }) {  (error) in
            print(error.description)
            
        }
    }

}




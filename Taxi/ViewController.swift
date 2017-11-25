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

    let url = "uberauth://connect?third_party_app_name=Taxi&callback_uri_string=com.weza.Taxi://oauth/consumer&client_id=_2-sGt68alcZwmZegdUlphXew-HQNVaS&scope=profile"
    var token : String?
    var  oath : OAuth2Swift?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoginButton()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = UserDefaults.standard.string(forKey: "T"){
            //let vc = UberVC()
            //self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginas(_ sender: Any) {
        self.uber()
    }
    
    
    func addLoginButton(){
        let scopes: [RidesScope] = [.profile,.allTrips,.request,.requestReceipt]
        let loginManager = LoginManager(loginType: .native)
        let loginButton = LoginButton(frame: CGRect.zero, scopes: scopes, loginManager: loginManager)
        loginButton.presentingViewController = self
        loginButton.delegate = self
        loginButton.frame = CGRect(x: 50, y: 170, width: 270, height: 50)
        view.addSubview(loginButton)
    }
    
    func uber(){
       
        oath = OAuth2Swift(consumerKey: "_2-sGt68alcZwmZegdUlphXew-HQNVaS", consumerSecret: "ZSVqMGSzqS8rAPP7aikVqDlsATUqhZbo5PJu9dsT", authorizeUrl: "https://login.uber.com/oauth/v2/authorize", accessTokenUrl: "https://login.uber.com/oauth/v2/token", responseType: "code")
        
        
        
        if #available(iOS 9.0, *) {
            oath?.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oath!)
        } else {
            // Fallback on earlier versions
        }
        
        oath!.authorize(withCallbackURL: "com.weza.Taxi://oauth/consumer", scope: "request", state: "UBER", success: { (credential, response, parameters) in
            print(credential.oauthToken)
            print(credential.oauthTokenSecret)
            
            
        }) {  (error) in
            print(error._domain)
            print(error._code)
            print(error.description)
            
        }
    }

}

extension ViewController : LoginButtonDelegate{
    func loginButton(_ button: LoginButton, didLogoutWithSuccess success: Bool) {
        
    }
    
    func loginButton(_ button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?) {
        print("\(String(describing: accessToken)):\(String(describing: error))")
        self.token = accessToken?.tokenString
        print(self.token)
        UserDefaults.standard.set(self.token, forKey: "T")
       
    }
}


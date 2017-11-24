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

let clientID = "_2-sGt68alcZwmZegdUlphXew-HQNVaS"
let sereverToken = "4yH7FvfOd3gyYKksLA3d3_Q5HdKDDwp9G35we5cZ"
let myAccessToken = "KA.eyJ2ZXJzaW9uIjoyLCJpZCI6IkNWSGxrT2xjUkFpZGdjbjNzNGZNYWc9PSIsImV4cGlyZXNfYXQiOjE1MTQwNjAzMjQsInBpcGVsaW5lX2tleV9pZCI6Ik1RPT0iLCJwaXBlbGluZV9pZCI6MX0"

class ViewController: UIViewController {

    var token : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoginButton()
        self.addRideRequestButton()
    }
    
    @IBAction func btnlogin(_ sender: Any) {
        //self.login()
        let location = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
        let drop = CLLocation(latitude: 12.9591722, longitude: 77.99741899999997)
        let client = RidesClient()
        client.fetchProducts(pickupLocation: location) { (products, response) in
            print(products)
            for product in products{
                print(product.productID)
                print(product.capacity)
            }
        }
        
//        client.fetchPriceEstimates(pickupLocation: location, dropoffLocation: drop) { (price, response) in
//            for p in price{
//                print("\(p.lowEstimate!):\(p.name!)")
//
//            }
//        }
  
        
    }
    
    @IBAction func tapped(_ sender: Any) {
        print("tapped")
    }
    
    // Swift
    func addLoginButton(){
        let scopes: [RidesScope] = [.profile]
        let loginManager = LoginManager(loginType: .native)
        let loginButton = LoginButton(frame: CGRect.zero, scopes: scopes, loginManager: loginManager)
        loginButton.presentingViewController = self
        loginButton.delegate = self
        loginButton.frame = CGRect(x: 50, y: 170, width: 270, height: 50)
        view.addSubview(loginButton)
    }
 
    func addRideRequestButton(){
        let t = UserDefaults.standard.string(forKey: "T")
        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
        let dropoffLocation = CLLocation(latitude: 12.9591722, longitude: 77.99741899999997)
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = "Somewhere"
        builder.dropoffAddress = "123 Fake St."
        builder.productID = "db6779d6-d8da-479f-8ac7-8068f4dade6f"
        let rideParameters = builder.build()
        let client = RidesClient()
        print(client.hasServerToken)
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        let btn = RideRequestButton(client: client, rideParameters: rideParameters, requestingBehavior: behavior)
        btn.frame = CGRect(x: 1, y: 70, width: 370, height: 100)
        btn.loadRideInformation()
        btn.removeTarget(nil, action: nil, for: .allEvents)
        btn.addTarget(self, action: #selector(ViewController.dosome), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.delegate = self
    }
    
    @objc func dosome(){
////        let url = URL(string: "uber://?action=applyPromo&client_id=\(clientID)&promo=BLR50")
////        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//
//    let url = URL(string: "https://api.uber.com/v1.2/me")
//        let request = NSMutableURLRequest(url: url!)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "PATCH"
//        request.addValue("Bearer e23ye2738hy2", forHTTPHeaderField: "Authorization")
//        let body = ["applied_promotion_codes": "FREE_RIDEZ" ]
//        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
//
//        URLSession.shared.dataTask(with: request as URLRequest ) { (data, response, error) -> Void in
//            print(response)
//            }.resume()
//
    }
   
   
}

extension ViewController : RideRequestViewControllerDelegate{
    func rideRequestViewController(_ rideRequestViewController: RideRequestViewController, didReceiveError error: NSError) {
        let errorType = RideRequestViewErrorType(rawValue: error.code) ?? .unknown
        
        switch errorType {
        case .accessTokenMissing:
        print("No access token ")
        case .accessTokenExpired:
        print("access token expired")
        case .networkError:
        print("network error")
        case .notSupported:
        print("not supported")
        default:
            print("default")
        }
    }
}

extension ViewController : RideRequestButtonDelegate{
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        print("load ride Inforamation")
    }
    
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        print("button error")
    }
}

extension ViewController : LoginButtonDelegate{
    func loginButton(_ button: LoginButton, didLogoutWithSuccess success: Bool) {
        
    }
    
    func loginButton(_ button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?) {
        print("\(String(describing: accessToken)):\(String(describing: error))")
        self.token = accessToken?.tokenString
        UserDefaults.standard.set(self.token, forKey: "T")
       
    }
}


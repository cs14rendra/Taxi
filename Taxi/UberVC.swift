//
//  UberVC.swift
//  Taxi
//
//  Created by surendra kumar on 11/24/17.
//  Copyright © 2017 surendra kumar. All rights reserved.
//

import UIKit
import UberRides
import CoreLocation

class UberVC: UIViewController {
    
    
    var client : RidesClient?
    var rideParameters : RideParameters?
    var rideprmarray = [RideParameters]()
    
    override func loadView() {
        Bundle.main.loadNibNamed("UberVC", owner: self, options: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let accessTokenID = UserDefaults.standard.string(forKey: "T")
        print(accessTokenID)
        client = RidesClient(accessTokenIdentifier: "my")
        self.BookaRide()
    }
    
    func addRideRequestButton(param : RideParameters, po: Int ){
        let t = UserDefaults.standard.string(forKey: "T")
        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
        let dropoffLocation = CLLocation(latitude: 12.9591722, longitude: 77.79741899999997)
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = "Somewhere"
        builder.dropoffAddress = "123 Fake St."
        builder.productID = "db6779d6-d8da-479f-8ac7-8068f4dade6f"
        rideParameters  = builder.build()
        let client = RidesClient()
        print(client.hasServerToken)
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        let btn = RideRequestButton(client: client, rideParameters: param, requestingBehavior: behavior)
        btn.frame = CGRect(x: 1, y: po, width: 300, height: 50)
        btn.loadRideInformation()
        btn.removeTarget(nil, action: nil, for: .allEvents)
        btn.addTarget(self, action: #selector(dosome), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.delegate = self
    }
    @objc func dosome(){
        self.BookaRide()
    }
    
    func BookaRide(){
        let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
        
        client?.fetchProducts(pickupLocation: pickupLocation, completion: { (products, res) in
            for product in products{
                
                let builder = RideParametersBuilder()
                let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
                let dropoffLocation = CLLocation(latitude: 12.9591722, longitude: 77.79741899999997)
                builder.pickupLocation = pickupLocation
                builder.dropoffLocation = dropoffLocation
                builder.dropoffNickname = "Somewhere"
                builder.dropoffAddress = "123 Fake St."
                builder.productID = product.productID
                let p  = builder.build()
                self.rideprmarray.append(p)
                var po = 0
                for i in self.rideprmarray{
//
//                    self.client?.requestRide(parameters: i, completion: { (ride, res) in
//
//                        print(ride?.driver?.name)
//                        print(res.error?.code)
//
//                    })
                    self.addRideRequestButton(param: i, po: po)
                    po = po + 50
                }
                
            }
        })
        
        
//        client?.fetchTripHistory(completion: { (history, res) in
//            for item in (history?.history)! {
//                print(item.startCity.name)
//            }
//            print(res.error)
//        })
//
//        client?.fetchPaymentMethods(completion: { (payarray, pay, res) in
//            for item in payarray{
//                print("\(item.type) :\(item.paymentDescription)")
//
//            }
//
//            print(pay?.type)
//        })
        
//        client?.fetchRideReceipt(requestID: "873712bxey", completion: { (ride, rs) in
//            print(ride?.duration)
//        })
    }
}




extension UberVC : RideRequestButtonDelegate{
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        print("load ride Inforamation")
    }
    
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        print("button error")
    }
}


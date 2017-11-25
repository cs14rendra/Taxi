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
    
    override func loadView() {
        Bundle.main.loadNibNamed("UberVC", owner: self, options: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addRideRequestButton()
        let accessTokenID = UserDefaults.standard.string(forKey: "T")
        client = RidesClient(accessTokenIdentifier: accessTokenID!)
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
        rideParameters  = builder.build()
        let client = RidesClient()
        print(client.hasServerToken)
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        let btn = RideRequestButton(client: client, rideParameters: rideParameters!, requestingBehavior: behavior)
        btn.frame = CGRect(x: 1, y: 70, width: 370, height: 100)
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
        client?.requestRide(parameters: rideParameters!, completion: { (ride, res) in
            print(ride?.driver?.name)
            print(res.error?.code)
        })
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


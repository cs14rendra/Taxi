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
    
    @IBOutlet var tableView: UITableView!
    
    var client : RidesClient?
    var rideParameters : RideParameters?
    var rideprmarray = [RideParameters](){
        didSet{
            DispatchQueue.main.async {
                 self.tableView.reloadData()
            }
        }
    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("UberVC", owner: self, options: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nim = UINib(nibName: "UberC", bundle: nil)
        self.tableView.register(nim, forCellReuseIdentifier: "Cell")
        let accessTokenID = UserDefaults.standard.string(forKey: "T")
        print(accessTokenID)
        client = RidesClient(accessTokenIdentifier: "my")
        self.fetchAllProduct()
        
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
    
    func fetchAllProduct (){
        let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
        
        client?.fetchProducts(pickupLocation: pickupLocation, completion: { (products, res) in
            let builder = RideParametersBuilder()
            let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
            let dropoffLocation = CLLocation(latitude: 12.9591722, longitude: 77.79741899999997)
            builder.pickupLocation = pickupLocation
            builder.dropoffLocation = dropoffLocation
            builder.dropoffNickname = "Somewhere"
            builder.dropoffAddress = "123 Fake St."
        
            var ride = [RideParameters]()
            for product in products{
                builder.productID = product.productID
                let parameter  = builder.build()
                ride.append(parameter)
            }
            self.rideprmarray = ride
        })
    }
    
    func BookaRide(){
        
        
        
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

extension UberVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideprmarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UberC
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        let param = self.rideprmarray[indexPath.row]
        let btn = RideRequestButton(client: self.client!, rideParameters: param, requestingBehavior: behavior)
        btn.frame = CGRect(x: 10, y: 20, width: cell.contentView.bounds.size.width-20, height: 110)
        btn.loadRideInformation()
        btn.removeTarget(nil, action: nil, for: .allEvents)
        //btn.addTarget(self, action: #selector(dosome), for: .touchUpInside)
        btn.delegate = self
        cell.contentView.addSubview(btn)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parameterts = self.rideprmarray[indexPath.row]
        self.requestRide(p: parameterts)
    }
    
    func requestRide(p : RideParameters){
        let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
        let dropoffLocation = CLLocation(latitude: 12.9591722, longitude: 77.79741899999997)
        var method = [PaymentMethod]()
        
        client?.fetchPaymentMethods(completion: { (payarr, pay, res) in
            method = payarr
            for meth in method {
               print(meth.type)
            }
            var surgeID : String?
            var productID : String?
            
            self.client?.fetchPriceEstimates(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation, completion: { (priceestimate, res) in
                for price in priceestimate{
                    print(price.surgeConfirmationID)
                    print(price.productID)
                    surgeID = price.surgeConfirmationID
                    productID = price.productID
                }
                let builder = RideParametersBuilder()
                builder.pickupLocation = pickupLocation
                builder.dropoffLocation = dropoffLocation
                builder.dropoffNickname = "Somewhere"
                builder.dropoffAddress = "123 Fake St."
                builder.paymentMethod = method[1].methodID
                builder.productID = productID!
                builder.surgeConfirmationID = surgeID
                self.client?.requestRide(parameters: builder.build(), completion: { (ride
                , res) in
                    print(ride?.driver?.name)
                })
                
            })
        })
        
       
    
        
        
    }
}


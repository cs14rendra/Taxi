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

let op = "ee4cc08e-b162-4fdb-a43e-f8276ba01e34"
let pickupLocation = CLLocation(latitude: 12.9591722, longitude: 77.69741899999997)
let dropoffLocation = CLLocation(latitude: 12.9279232, longitude: 77.62710779999998)

class UberVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var managerUber : Uber?
    var accessToken : String?
    var client : RidesClient?
    var rideParameters : RideParameters?
    var requestID : String?
    var paymentMethod  = [PaymentMethod]()
    
    var parameters = [RideParameters](){
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
        let nim = UINib(nibName: "UberC", bundle: nil)
        self.tableView.register(nim, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
        
       
        client = RidesClient(accessTokenIdentifier: "my")
        accessToken = TokenManager.fetchToken(identifier: "my")?.tokenString
        if let _ = accessToken {
            managerUber = Uber(accessToken: accessToken!)
        }
        
        self.fetchAllProductParameters()
        self.getPaymentMethod()
    }
    
    @IBAction func cancel(_ sender: Any) {
      
        self.cancleCurrrentRide()
    }
    
    @IBAction func getCurrentStatus(_ sender: Any) {
        
        managerUber?.geCurrentStatus(completion: { (requestID, status, error) in
            guard error == nil else {
                return
            }
            guard let id = requestID, id == nil , let sts = status , sts == nil else {
                self.alert(title: "Error", message: "NO current Ride")
                return
            }
            self.alert(title: "Current Ride", message: "\(sts)")
        })
        
    }
    
    
    @IBAction func status(_ sender: Any) {
        guard let rideID = self.requestID else {
            self.alert(title: "Error!", message: "request ID is nil")
            return
        }
        managerUber?.changeStatus(ofRiding: rideID, to: "accepted", completion: { (statusCode) in
            self.alert(title: "Status", message: "\(statusCode)")
        })
    }
    
    
    
    func cancleCurrrentRide(){
        managerUber?.cancelRide(completion: { (ack) in
            guard ack == nil else {
                self.alert(title: "Error!", message: "Can't cancle request")
                return
            }
            self.alert(title: "successfully", message: "cancled last Trip")
        })
    }
    
    func getPaymentMethod(){
        client?.fetchPaymentMethods(completion: { (payments, recentPayment, res) in
            for payment in payments{
                self.paymentMethod.append(payment)
            }
        })
    }
    
    func getcashpayMethodID() -> String? {
        var cash : String?
        for pay in self.paymentMethod{
            if pay.type == "cash"{
                cash = pay.methodID
            }
        }
        return cash
    }
    
    func fetchAllProductParameters (){
        client?.fetchProducts(pickupLocation: pickupLocation, completion: { (products, res) in
            let builder = RideParametersBuilder()
            builder.pickupLocation = pickupLocation
            builder.dropoffLocation = dropoffLocation
            builder.dropoffNickname = "rt nagar"
            builder.dropoffAddress = "123 rt nagar 536069"
            var ride = [RideParameters]()
            for product in products{
                builder.productID = product.productID
                let parameter  = builder.build()
                ride.append(parameter)
            }
            self.parameters = ride
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

extension UberVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parameters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UberC
        let view = cell.viewWithTag(indexPath.row)
        if view == nil {
            let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
            let param = self.parameters[indexPath.row]
            let btn = RideRequestButton(client: self.client!, rideParameters: param, requestingBehavior: behavior)
            
            btn.frame = CGRect(x: 10, y: 20, width: cell.contentView.bounds.size.width-20, height: 110)
            btn.tag = indexPath.row
            btn.loadRideInformation()
            btn.removeTarget(nil, action: nil, for: .allEvents)
            btn.addTarget(self, action: #selector(UberVC.dosome(sender:)), for: .touchUpInside)
            btn.delegate = self
            cell.contentView.addSubview(btn)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension UberVC  {
    
    @objc func dosome(sender : UIButton){
        let parameter = self.parameters[sender.tag]
        let productID = self.parameters[sender.tag].productID
        self.estimatedParameter(fromParameter: parameter) { fairID in
            let payID = self.getcashpayMethodID()
            // TODO : Remore force unwrapping
            self.managerUber?.requestforfinalRide(forfairID: fairID!, and: productID!, paymentMethodID: payID!, completion: { requestID, error, errorTitle in
                guard error == nil else {
                    self.alert(title: "Error!", message: (error?.localizedDescription)!)
                    return
                }
                if  let title = errorTitle {
                    self.alert(title: "Error!", message: title)
                    return
                }
            
                self.requestID = requestID!
                self.alert(title: "Success!", message: "Booked at \(self.requestID!)")
            })
        }
    }
    
    
    func estimatedParameter(fromParameter parameter : RideParameters, completion: @escaping (String?)->()){
        let builder = RideParametersBuilder()
        builder.pickupLocation = parameter.pickupLocation
        builder.dropoffLocation = parameter.dropoffLocation
        builder.productID = parameter.productID
        
        self.client?.fetchRideRequestEstimate(parameters: builder.build(), completion: { (estimate, res) in
            completion(estimate?.fare?.fareID)
        })
    }
}


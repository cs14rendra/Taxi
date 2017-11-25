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
    
    
    
    @IBAction func cancel(_ sender: Any) {
       self.changeStatus()
       
    }
    
    @IBAction func status(_ sender: Any) {
        self.getStatus()
    }
    
    
    @IBOutlet var tableView: UITableView!
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
        
        self.fetchAllProductParameters()
        self.getPaymentMethod()
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
            //print("\(pay.type):\(pay.paymentDescription):\(pay.methodID)")
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
        
        return cell
    }
    
    @objc func dosome(sender : UIButton){
        
                let parameter = self.parameters[sender.tag]
        let productID = self.parameters[sender.tag].productID
        self.estimatedParameter(fromParameter: parameter) { (fairID) in
            print(fairID)
            self.requestforfinalRide(forfairID: fairID!, and: productID!, completion: {
                if let id = self.requestID{
                    self.client?.fetchRideDetails(requestID: id, completion: { (ride, res) in
                        print(ride?.status)
                    })
                }

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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    
    func requestforfinalRide(forfairID id : String,and productID : String,completion:@escaping ()->()){
        let session = self.getSession()
        let url = URL(string: "https://sandbox-api.uber.com/v1.2/requests")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //let id : String = (self.products.first?.productID)!
        let startlat = "\(pickupLocation.coordinate.latitude)"
        let startlong = "\(pickupLocation.coordinate.longitude)"
        let endlat = "\(dropoffLocation.coordinate.latitude)"
        let endlog = "\(dropoffLocation.coordinate.longitude)"
        let paymentMethodID = self.getcashpayMethodID()
        
        let body = ["product_id": productID,
                    "start_latitude":startlat,
                    "start_longitude": startlong,
                    "end_latitude":endlat,
                    "end_longitude": endlog,
                    "fare_id":id,
            "payment_method_id" : paymentMethodID!
        ]
        
        try! request.httpBody = JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        
        
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            let j = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            if let value = j as? [String: AnyObject] {
                if let a = value["request_id"] as? String{
                    self.requestID = a
                }
            }
            
            if let value = j as? [String: AnyObject]{
                if let er = value["errors"] {
                    print(er)
                    if let code = er["code"] as? String{
                        print(code)
                    }
                }
            }
            print(j)
            completion()
            }.resume()
    }
    
    
    func getSession() -> URLSession{
        let authValue : String = "Bearer \(accessToken!)"
        let  sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = ["Authorization": authValue]
        let session = URLSession(configuration: sessionConfig)
        return session
        
    }
    
    func changeStatus(){
        let session = self.getSession()
        let url = URL(string: "https://sandbox-api.uber.com/v1.2/requests/c3e34783-2304-4566-9f83-b417091fc7d3")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("en_US", forHTTPHeaderField: "Accept-Language")
        
        let body = ["status":"accepted"]
        
        try! request.httpBody = JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        
        
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            let j = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            print(j)
            }.resume()
        
    }
    
    func getStatus(){
        let session = self.getSession()
        let url = URL(string: "https://sandbox-api.uber.com/v1.2/requests/current")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("en_US", forHTTPHeaderField: "Accept-Language")
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            let j = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            print(j)
        }.resume()
    }

}


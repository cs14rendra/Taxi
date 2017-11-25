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
let dropoffLocation = CLLocation(latitude: 12.9591722, longitude: 77.79741899999997)

class UberVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var accessToken : String?
    var client : RidesClient?
    var rideParameters : RideParameters?
    var requestID : String?
    
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
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nim = UINib(nibName: "UberC", bundle: nil)
        self.tableView.register(nim, forCellReuseIdentifier: "Cell")
        let accessTokenID = UserDefaults.standard.string(forKey: "T")
        print(accessTokenID)
        client = RidesClient(accessTokenIdentifier: "my")
        self.fetchAllProductParameters()
        self.tableView.allowsSelection = false
        accessToken = TokenManager.fetchToken(identifier: "my")?.tokenString
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
        
        let body = ["product_id": productID,
                    "start_latitude":startlat,
                    "start_longitude": startlong,
                    "end_latitude":endlat,
                    "end_longitude": endlog,
                    "fare_id":id
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

}


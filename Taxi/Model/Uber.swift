 //
//  Uber.swift
//  Taxi
//
//  Created by surendra kumar on 11/26/17.
//  Copyright © 2017 surendra kumar. All rights reserved.
//

import Foundation

class Uber {
    private var accessToken : String
    init(accessToken : String) {
        self.accessToken = accessToken
    }
   
    func requestforfinalRide(forfairID id : String,and productID : String,paymentMethodID: String,completion:@escaping (_ RequesID:String?,_ error: Error?,_ errorTitle : String?)->()){
        let session = self.getSession()
        var urlString = BASEURL
        urlString += "/requests"
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let startlat = "\(pickupLocation.coordinate.latitude)"
        let startlong = "\(pickupLocation.coordinate.longitude)"
        let endlat = "\(dropoffLocation.coordinate.latitude)"
        let endlog = "\(dropoffLocation.coordinate.longitude)"
        let paymentMethodID = paymentMethodID
        
        let body = ["product_id": productID,
                    "start_latitude":startlat,
                    "start_longitude": startlong,
                    "end_latitude":endlat,
                    "end_longitude": endlog,
                    "fare_id":id,
                    "payment_method_id" : paymentMethodID
        ]
       do {
        try request.httpBody = JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
       }catch{
        print(error.localizedDescription)
        completion(nil,error, nil)
        }
        
        
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard error == nil else {
                completion(nil,error, nil)
                return
            }
            guard let dataFromServer = data else {
                completion(nil,error, nil)
                return
            }
            
            let res = response as! HTTPURLResponse
            guard  res.statusCode == 202 else {
                do {
                    let j = try JSONSerialization.jsonObject(with: dataFromServer, options: JSONSerialization.ReadingOptions.allowFragments)
                    print(j)
                    
                    if let value = j as? [String: AnyObject] {
                        print(value)
                        if let a = value["errors"]{
                            print(a)
                            if let b = a as? NSArray{
                                if  let c = b.firstObject as? [String:AnyObject]{
                                    if let errorCode = c["code"] as? String {
                                        print(errorCode)
                                        completion(nil, nil, errorCode)
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    print(error.localizedDescription)
                    completion(nil,error, nil)
                }
             return
            }
            
            do {
                let j = try JSONSerialization.jsonObject(with: dataFromServer, options: JSONSerialization.ReadingOptions.allowFragments)
                 print(j)
                if let value = j as? [String: AnyObject] {
                    if let a = value["request_id"] as? String{
                        completion(a,nil, nil)
                    }
                }
            }catch{
                print(error.localizedDescription)
                completion(nil,error, nil)
            }
        }.resume()
    }
    
    func geCurrentStatus(completion: @escaping (_ requestID : String?,_ status: String?, _ error : Error?)->()){
        let session = self.getSession()
        var urlString = BASEURL
        urlString += "/requests/current"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("en_US", forHTTPHeaderField: "Accept-Language")
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                completion(nil, nil, error)
                return
            }
            let res = response as! HTTPURLResponse
            guard res.statusCode == 200 else {
                completion(nil, nil, nil)
                return
            }
            do{
                let j = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                if let value = j as? [String: AnyObject]{
                    if let requestID = value["request_id"] as? String{
                        if let status = value["status"] as? String{
                            completion(requestID, status, nil)
                        }
                     }
                
                }
                
            }catch{
                completion(nil, nil, nil)
            }
            }.resume()
    }
    
    func cancelRide(completion:@escaping (_ ack:String?)->()){
        let session = self.getSession()
        var urlString = BASEURL
        urlString += "/requests/current"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            let res = response as! HTTPURLResponse
            guard res.statusCode == 204 else {
                completion("failed")
                return
            }
            print(res.statusCode)
            completion(nil)
            }.resume()
    }

    func stuatusofRide(rideID: String){
        let session = self.getSession()
        var urlString = BASEURL
        urlString += "/requests/\(rideID)"
        let url = URL(string: urlString)
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

extension Uber {
    private func getSession() -> URLSession{
        let authValue : String = "Bearer \(accessToken)"
        let  sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = ["Authorization": authValue]
        let session = URLSession(configuration: sessionConfig)
        return session
        
    }
}

// For Simulation
extension Uber {
    func changeStatus(ofRiding requestID: String, to status : String, completion:@escaping (_ responseCode : Int)->()){
        let someRandomResponse = -1
        let session = self.getSession()
        var urlString  = BASEURL
        urlString += "/sandbox/requests/\(requestID)"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["status":"\(status)"]
        do{
            try request.httpBody = JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        }catch{
            print(error.localizedDescription)
            completion(someRandomResponse)
        }
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            guard error == nil else {
                completion(someRandomResponse)
                return
            }
            guard let dataS = data else {
                completion(someRandomResponse)
                return
            }
            let r = response as? HTTPURLResponse
                completion((r?.statusCode)!)
            
            }.resume()
        
    }
}

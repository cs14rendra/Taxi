//
//  UbreIOSAPI.swift
//  Taxi
//
//  Created by surendra kumar on 5/17/18.
//  Copyright © 2018 surendra kumar. All rights reserved.
//

import Foundation
import UIKit
import UberRides
import CoreLocation

class UberIOSAPI: UIViewController {
    @IBOutlet weak var lb: UILabel!
    var cab = [Cab]()
    @IBOutlet weak var tableView: UITableView!
    @IBAction func bt(_ sender: Any) {
        let manager = LoginManager()
        manager.login(requestedScopes: [.request], presentingViewController: self) { (_token, error) in
            guard error == nil else {
                print("Error to login:\(error!.localizedDescription)")
                return
            }
            guard let token = _token else {return}
            print(token)

        }
        
        //requestRide()
    }
    
    func requestRide(){
        let ridesClient = RidesClient(accessTokenIdentifier: (TokenManager.fetchToken()?.tokenString)!)
        let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
        let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
        let builder = RideParametersBuilder()
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        
        ridesClient.fetchProducts(pickupLocation: pickupLocation) { (_product, res) in
            
            let group = DispatchGroup()
            for product in _product{
                group.enter()
                let id = product.productID
                builder.productID = id
                ridesClient.fetchRideRequestEstimate(parameters: builder.build(), completion: { (ride, res) in
                    print(res.response?.description)
                    let fare = ride?.priceEstimate
                    print(ride)
                    let cab = Cab(price: fare?.estimate, distance: nil, cabType: product.name)
                    self.cab.append(cab)
                    group.leave()
                })
            }
            group.notify(queue: DispatchQueue.main, execute: {
                self.tableView.reloadData()
            })
    
    }
}
}

extension UberIOSAPI : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cab.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = cab[indexPath.row].price
        cell?.detailTextLabel?.text = cab[indexPath.row].price
        return cell!
    }
    
    
}

//
//  Cab.swift
//  Taxi
//
//  Created by surendra kumar on 5/17/18.
//  Copyright © 2018 surendra kumar. All rights reserved.
//

import Foundation

class Cab {
    let cabType: String
    let price : String?
    let distance: String?
    
    init(price : String?, distance : String?,cabType: String) {
        self.price = price
        self.distance    = distance
        self.cabType = cabType
    }
}

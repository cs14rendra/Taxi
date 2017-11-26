//
//  Uber.swift
//  Taxi
//
//  Created by surendra kumar on 11/26/17.
//  Copyright © 2017 surendra kumar. All rights reserved.
//

import Foundation
class Uber {
    static let _shared = Uber()
    
    static var shared : Uber{
        return _shared
    }
    
    
}

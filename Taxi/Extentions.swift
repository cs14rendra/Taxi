//
//  Extentions.swift
//  Taxi
//
//  Created by surendra kumar on 11/26/17.
//  Copyright © 2017 surendra kumar. All rights reserved.
//

import Foundation
import  UIKit

extension UIViewController{
    func alert(title :String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

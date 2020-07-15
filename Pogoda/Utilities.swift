//
//  Utilities.swift
//  Pogoda
//
//  Created by Lukasz Chrzanowski on 22/01/2017.
//  Copyright © 2017 LC. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Continue", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

enum Location {
    case cityName(name: String)
    case zipCode(zipCode: String)
    case coords(latitude: Double, longitude: Double)
}


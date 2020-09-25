//
//  UIViewController+ShowError.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func showMsgAlert(title: String, msg: String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    func showErrorAlert(title: String, msg: String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
}

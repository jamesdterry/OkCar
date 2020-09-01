//
//  SettingsViewController.swift
//  OkCar
//
//  Created by James Terry on 9/1/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import MaterialTextField
import PureLayout

class SettingsViewController: ScrollableContentViewController {
    typealias Container = CarServiceSingleton & ViewControllerFactory
    private let container: Container

    private lazy var carService = container.getCarService()
    
    init(container: Container) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .systemBackgroundPre13
        }
        
        if title == nil {
            title = "Settings"
        }
    }
}

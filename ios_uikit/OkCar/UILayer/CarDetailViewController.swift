//
//  CarDetailViewController.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import PureLayout
import MapKit

class CarDetailViewController: ScrollableContentViewController {

    var car: CarModel!
    
    let nameLabel = UILabel()
    private let carMapView = MKMapView()
    private let carDetailView = CarDetailView()
    private let callButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

    init(car: CarModel) {
        self.car = car
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
        
        carMapView.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.addArrangedSubview(carMapView)
        carMapView.autoMatch(.height, to: .width, of: self.view, withMultiplier: 0.5)
            
        carDetailView.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.addArrangedSubview(carDetailView)
        
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setTitle("Call", for: .normal)
        callButton.autoSetDimension(.height, toSize: 44)
        fieldsStack.addArrangedSubview(callButton)
        callButton.addTarget(self, action:#selector(callTapped), for: .touchUpInside)
        callButton.setTitleColor(.systemBlue, for: .normal)
        if #available(iOS 13.0, *) {
            callButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            callButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }
        callButton.layer.borderWidth = 1
        callButton.layer.borderColor = UIColor.systemBlue.cgColor
        callButton.layer.cornerRadius = 4

        bind(car)
    }
    
    @objc func callTapped() {
    }
    
    func bind(_ car: CarModel) {
        
        let center = CLLocationCoordinate2D(latitude: car.llat, longitude: car.llong)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        
        carMapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.title = car.make
        annotation.coordinate = center
        carMapView.addAnnotation(annotation)

        carDetailView.bind(car, size: .large)
    }

}

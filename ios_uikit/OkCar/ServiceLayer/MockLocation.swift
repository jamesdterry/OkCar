//
//  MockLocation.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation
import MapKit

class MockLocation: NSObject, OkCarLocationProtocol {
    var delegate: OkCarLocationDelegate?
    
    private let defaultLocation = CLLocation(latitude: 41.6, longitude: -83.52)

    func requestPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) { [unowned self] in
            self.delegate?.updatedAuthorization(OkCarLocationAuthorization.available)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) { [unowned self] in
                self.delegate?.updatedLocation(self.defaultLocation)
            }
        }
    }
    
    func requestCurrentLocation() -> CLLocation? {
        return defaultLocation
    }
    
}

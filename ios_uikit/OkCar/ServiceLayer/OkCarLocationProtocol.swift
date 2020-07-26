//
//  OkCarLocationProtocol.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation
import MapKit

enum OkCarLocationAuthorization {
    case unknown
    case available
    case unavailable
}

protocol OkCarLocationDelegate: AnyObject {
    func updatedAuthorization(_ authorization: OkCarLocationAuthorization)
    func updatedLocation(_ location: CLLocation)
}

protocol OkCarLocationProtocol {
    var delegate: OkCarLocationDelegate?  { get set }
    func requestPermission()
    func requestCurrentLocation() -> CLLocation?
}

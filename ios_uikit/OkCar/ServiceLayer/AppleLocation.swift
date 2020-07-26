//
//  AppleLocation.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation
import MapKit

class AppleLocation: NSObject, OkCarLocationProtocol {
    public weak var delegate: OkCarLocationDelegate?
    
    private var lastLocation: CLLocation?
    private var locationManager: CLLocationManager
    private var lastAuthorizationStatus: CLAuthorizationStatus?
    
    private let defaultLocation = CLLocation(latitude: 41.6, longitude: -83.52)
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func requestPermission() {
        if let lastAuthorizationStatus = lastAuthorizationStatus {
            switch lastAuthorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted, .denied:
                delegate?.updatedAuthorization(.unavailable)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                delegate?.updatedAuthorization(.available)
                break
            @unknown default:
                break
            }
        }
        
    }
    
    func requestCurrentLocation() -> CLLocation? {
        if let location = locationManager.location {
            self.lastLocation = location
            return location
        } else {
            if let lastAuthorizationStatus = lastAuthorizationStatus {
                switch lastAuthorizationStatus {
                case .notDetermined, .restricted, .denied:
                    return defaultLocation
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.requestLocation()
                    if let lastLocation = self.lastLocation {
                        return lastLocation
                    }
                    break
                @unknown default:
                    break
                }
            }
            
            return nil
        }
    }
    
}

extension AppleLocation: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.lastAuthorizationStatus = status
        
        switch status {
        case .notDetermined, .restricted, .denied:
            delegate?.updatedAuthorization(.unavailable)
            delegate?.updatedLocation(defaultLocation)
            break
        case .authorizedAlways, .authorizedWhenInUse:
            delegate?.updatedAuthorization(.available)
            locationManager.requestLocation()
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last {
            self.lastLocation = location
            delegate?.updatedLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                delegate?.updatedLocation(defaultLocation)
            case CLError.denied:
                break
            default:
                break
            }
        }
    }
}

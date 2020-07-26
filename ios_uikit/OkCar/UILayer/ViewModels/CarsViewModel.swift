//
//  CarsViewModel.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation

protocol CarViewModelUpdates: AnyObject {
    func hasMoreData()
}

public enum CarError: Error {
    case someError
}

extension CarError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .someError:
            return NSLocalizedString("Some Error", comment: "Some Error")
        }
    }
}

class CarsViewModel {
    public weak var delegate: CarViewModelUpdates?
    
    private let pageSize = 100
    private let reloadBoundry = 20
    private var allFetched = false
    private var fetchInProgress = false

    var carService: OkCarServiceProtocol?
        
    var cars: [CarModel] = []
    
    private var savedFilter: SearchFilters?
    private var savedLat = 0.0
    private var savedLong = 0.0

    init(service: OkCarServiceProtocol) {
        carService = service
    }
    
    func fetchCars(filter: SearchFilters,
                   llat: Double,
                   llong: Double,
                   completion: @escaping (Result<Bool, CarError>) -> Void)
    {
        guard let carService = carService else {
            completion(.failure(.someError))
            return
        }
        
        self.allFetched = false
        savedFilter = filter
        savedLat = llat
        savedLong = llat

        fetchInProgress = true
        carService.getCars(filter: filter, llat: llat, llong: llong, count: pageSize, offset: 0) { (result) in
            self.fetchInProgress = false
            
            if case .failure = result {
                completion(.failure(.someError))
                return
            }

            do {
                if let cars = try result.get() {
                    if cars.count < self.pageSize {
                        self.allFetched = true
                    }
                    
                    self.cars = cars
                } else {
                    self.cars = []
                    assert(false, "cars should not be nil")
                }
            } catch {
                self.cars = []
                assert(false, "Failed getting cars from success")
            }
            
            completion(.success(true))
        }
    }
    
    func access(row: Int) {
        if allFetched || fetchInProgress {
            return
        }
        
        guard let carService = carService else {
            return
        }
        
        guard let savedFilter = savedFilter else {
            return
        }

        if cars.count - row < reloadBoundry {
            fetchInProgress = true
            carService.getCars(filter: savedFilter, llat: savedLat, llong: savedLong, count: pageSize, offset: cars.count) { (result) in
                self.fetchInProgress = false
                
                if case .failure = result {
                    return
                }

                do {
                    if let cars = try result.get() {
                        if cars.count < self.pageSize {
                            self.allFetched = true
                        }
                        
                        self.cars.append(contentsOf: cars)
                    } else {
                        self.cars = []
                        assert(false, "cars should not be nil")
                    }
                } catch {
                    self.cars = []
                    assert(false, "Failed getting cars from success")
                }
                
                self.delegate?.hasMoreData()
            }

        }
    }
}

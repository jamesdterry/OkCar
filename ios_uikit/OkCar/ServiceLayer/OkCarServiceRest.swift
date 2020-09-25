//
//  OkCarServiceRest.swift
//  OkCar
//
//  Created by James Terry on 8/8/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation

class OkCarServiceRest: OkCarServiceProtocol {
    func startService() {
    }
    
    func currentUser() -> UserModel? {
        return nil
    }
    
    func login(email: String, password: String, completion: @escaping (Result<UserModel?, ServiceError>) -> Void) {
    }
    
    func signup(email: String, password: String, completion: @escaping (Result<UserModel?, ServiceError>) -> Void) {
    }
    
    func forgotPassword(email: String, completion: @escaping (Result<Bool, ServiceError>) -> Void) {
    }
    
    func updatePassword(password: String, completion: @escaping (Result<Bool, ServiceError>) -> Void) {
    }
    
    func logout() {
    }
    
    func getCars(filter: SearchFilters, llat: Double, llong: Double, count: Int, offset: Int, completion: @escaping (Result<[CarModel]?, ServiceError>) -> Void) {
    }
    
    func getCar(storageId: String, completion: @escaping (Result<CarModel?, ServiceError>) -> Void) {
    }
    
    func addCar(car: CarModel, completion: @escaping (Result<CarModel?, ServiceError>) -> Void) {
    }
    
    func updateCar(car: CarModel, completion: @escaping (Result<CarModel?, ServiceError>) -> Void) {
    }
    
    func deleteCar(car: CarModel, completion: @escaping (Result<Bool, ServiceError>) -> Void) {
    }
    
}

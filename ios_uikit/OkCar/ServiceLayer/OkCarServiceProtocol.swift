//
//  OkCarServiceProtocol.swift
//  OkCar
//
//  Created by James Terry on 7/19/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case notFound
    case invalidLogin
    case networkProblem
    case invalid
    case accountExists
    case accountDeleted
    case other
}

protocol OkCarServiceProtocol {
    func startService()
    
    func currentUser() -> UserModel?
    
    func login(email: String, password: String, completion: @escaping (Result<UserModel?, ServiceError>) -> Void)
    func signup(email: String, password: String, completion: @escaping (Result<UserModel?, ServiceError>) -> Void)
    func forgotPassword(email: String, completion: @escaping (Result<Bool, ServiceError>) -> Void)

    func logout()
    
    func getCars(filter: SearchFilters, llat: Double, llong: Double, count: Int, offset: Int,
                       completion: @escaping (Result<[CarModel]?, ServiceError>) -> Void)
    func getCar(storageId: String, completion: @escaping (Result<CarModel?, ServiceError>) -> Void)
    func addCar(car: CarModel, completion: @escaping (Result<CarModel?, ServiceError>) -> Void)
    func updateCar(car: CarModel, completion: @escaping (Result<CarModel?, ServiceError>) -> Void)
    func deleteCar(car: CarModel, completion: @escaping (Result<Bool, ServiceError>) -> Void)    
}

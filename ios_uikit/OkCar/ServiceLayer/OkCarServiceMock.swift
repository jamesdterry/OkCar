//
//  OkServiceMock.swift
//  OkCar
//
//  Created by James Terry on 7/19/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation

class OkCarServiceMock: OkCarServiceProtocol {
    private var userDict = [String: UserModel]()
    private var carDict = [String: CarModel]()
    private var mockCurrentUser: UserModel?

    init() {
        let user = UserModel(storageId: "AAA", email: "test@test.com")
        userDict[user.storageId!] = user
        
        let user2 = UserModel(storageId: randomString(12), email: "test2@test.com")
        userDict[user2.storageId!] = user2

        let user3 = UserModel(storageId: randomString(12), email: "test3@test.com")
        userDict[user3.storageId!] = user3

        for i in 1...2 {
            let userN = UserModel(storageId:randomString(12),
                                  email: "user\(i)@mock.com")
            userDict[userN.storageId!] = userN
        }
        
        let car1 = CarModel(storageId: "qC42OseGq8",
                            seller: user,
                            make: "Honda",
                            model: "CR-V",
                            type: "SUV",
                            color: "Silver",
                            location: "Portsmouth, NH",
                            description: "Just traded is this nice low mileage 2018 Honda CR-V LX AWD in Lunar Silver over Gray Cloth",
                            mileage: 30442,
                            price: 18999,
                            llat: 41.0,
                            llong: -83.0,
                            media: ["https://jamesdterry.github.io/OkCar/img/honda_crv.jpg"])
        
        carDict[car1.storageId!] = car1
        
        let car2 = CarModel(storageId: randomString(12),
                            seller: user2,
                            make: "Ford",
                            model: "F150",
                            type: "Truck",
                            color: "Black",
                            location: "Salem, NH",
                            description: "A real workhorse, brand new tires and just passed inspection.",
                            mileage: 162200,
                            price: 4500,
                            llat: 41.1,
                            llong: -83.1,
                            media: ["https://jamesdterry.github.io/OkCar/img/ford_f150.jpg"])
        
        carDict[car2.storageId!] = car2
        
        let car3 = CarModel(storageId: randomString(12),
                            seller: user3,
                            make: "Tesla",
                            model: "Models S",
                            type: "Sedan",
                            color: "Blue",
                            location: "Rochester, NH",
                            description: "Turn heads with this ecologically friendly vehicle.",
                            mileage: 21444,
                            price: 64999,
                            llat: 41.2,
                            llong: -83.2,
                            media: ["https://jamesdterry.github.io/OkCar/img/tesla.jpg"])
        
        carDict[car3.storageId!] = car3
        
        // Optionally have someone logged in
        let mockUserName = UserDefaults.standard.string(forKey: "mock-user")?.lowercased()
        
        if mockUserName == "user" {
            mockCurrentUser = user
        }
    }

    func startService() {
    }

    func currentUser() -> UserModel? {
        return mockCurrentUser
    }
    
    func login(email: String, password: String, completion: @escaping (Result<UserModel?, ServiceError>) -> Void) {
        
        for (_, user) in userDict {
            if user.email == email {
                if password == "password" {
                    self.mockCurrentUser = user
                    completion(.success(user))
                    return
                }
            }
        }
        
        completion(.failure(.invalid))
    }
    
    func randomString(_ length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func signup(email: String, password: String, completion: @escaping (Result<UserModel?, ServiceError>) -> Void) {

        for (_, user) in userDict {
            if user.email == email {
                completion(.failure(.accountExists))
                return
            }
        }
        
        let user = UserModel(storageId: randomString(12), email: email)
        
        userDict[user.storageId!] = user
        self.mockCurrentUser = user
        completion(.success(user))
    }
    
    func logout() {
        self.mockCurrentUser = nil
    }
    
    func getCars(filter: SearchFilters, llat: Double, llong: Double, count: Int, offset: Int,
                       completion: @escaping (Result<[CarModel]?, ServiceError>) -> Void) {
        
        // Build list, then sort by distance
        var carList:[CarModel] = []
        
        for (_, car) in carDict {
            var ok = true
            
            switch filter.price.compare {
                case .greaterThan:
                    if car.price <= filter.price.value {
                        ok = false
                    }
                case .lessThan:
                    if car.price >= filter.price.value {
                        ok = false
                    }
                default:
                    break
            }
            
            switch filter.mileage.compare {
                case .greaterThan:
                    if car.mileage <= filter.mileage.value {
                        ok = false
                    }
                case .lessThan:
                    if car.mileage >= filter.mileage.value {
                        ok = false
                    }
                default:
                    break
            }
            
            if (ok) {
                carList.append(car)
            }
        }
        
        let sortedCarList = carList.sorted {
            
            let distance0 = sqrt(((llat - $0.llat) * (llat - $0.llat)) + ((llong - $0.llong) * (llong - $0.llong)))
            let distance1 = sqrt(((llat - $1.llat) * (llat - $1.llat)) + ((llong - $1.llong) * (llong - $1.llong)))

            return distance0 < distance1
        }
        
        if sortedCarList.count == 0 {
            completion(.success(sortedCarList))
            return
        }
        
        if offset >= sortedCarList.count {
            let emptyCarList:[CarModel] = []
            completion(.success(emptyCarList))
            return
        }
        
        let slicedCarList = sortedCarList[offset...min(offset+count-1, sortedCarList.count-1)]
        
        completion(.success(Array(slicedCarList)))
    }
    
    func getCar(storageId: String, completion: @escaping (Result<CarModel?, ServiceError>) -> Void) {
        if let car = carDict[storageId] {
            completion(.success(car))
        } else {
            completion(.failure(.notFound))
        }
    }
    
    func addCar(car: CarModel, completion: @escaping (Result<CarModel?, ServiceError>) -> Void) {
        
        let addedCar = CarModel(storageId: randomString(12),
                                seller: car.seller,
                                make: car.make,
                                model: car.model,
                                type: car.type,
                                color: car.color,
                                location: car.location,
                                description: car.description,
                                mileage: car.mileage,
                                price: car.price,
                                llat: car.llat,
                                llong: car.llong,
                                media: car.media)
        
        carDict[addedCar.storageId!] = addedCar
        completion(.success(addedCar))
    }
    
    func updateCar(car: CarModel, completion: @escaping (Result<CarModel?, ServiceError>) -> Void) {
        carDict[car.storageId!] = car
        completion(.success(car))
    }
    
    func deleteCar(car: CarModel, completion: @escaping (Result<Bool, ServiceError>) -> Void) {
        if let storageId = car.storageId, let _ = carDict[storageId] {
            carDict.removeValue(forKey: storageId)
            completion(.success(true))
        } else {
            completion(.failure(.notFound))
        }
    }
    
    func forgotPassword(email: String, completion: @escaping (Result<Bool, ServiceError>) -> Void)
    {
        completion(.success(true))
    }
}

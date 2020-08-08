//
//  ServiceTests.swift
//  OkCarTests
//
//  Created by James Terry on 7/19/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import XCTest

class ServiceTests: XCTestCase {
    let service = OkCarServiceMock()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        service.startService()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        service.logout()
    }

    func testLoginFails() throws {
        let expectation = self.expectation(description: "servicecall")

        service.login(email: "notfound@gmail.com", password: "1234") { (result) in
            if case .success = result {
                XCTAssert(false, "Login should fail")
            }
            XCTAssert(result == .failure(.invalid))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testLoginBadPassword() throws {
        let expectation = self.expectation(description: "servicecall")

        service.login(email: "test@test.com", password: "1234") { (result) in
            if case .success = result {
                XCTAssert(false, "Login should fail")
            }
            XCTAssert(result == .failure(.invalid))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testLogin() throws {
        let expectation = self.expectation(description: "servicecall")

        service.login(email: "test@test.com", password: "password") { (result) in
            if case .failure = result {
                XCTAssert(false, "Login should succeed")
            }
            do {
                if let user = try result.get() {
                    XCTAssert(user.email == "test@test.com", "User email wrong")
                } else {
                    XCTAssert(false, "User should not be nil")
                }
            } catch {
                XCTAssert(false, "Failed getting User from success")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testSignup() throws {
        let expectation = self.expectation(description: "servicecall")

        service.signup(email: "signuptest@test.com", password: "password") { (result) in
            if case .failure = result {
                XCTAssert(false, "Signup should succeed")
                return
            }
            do {
                if let user = try result.get() {
                    XCTAssert(user.email == "signuptest@test.com", "User email wrong")
                }
                expectation.fulfill()
            } catch {
                XCTAssert(false, "Failed getting User from success")
            }
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testGetCar() throws {
        let expectation = self.expectation(description: "servicecall")
        
        service.getCar(storageId: "qC42OseGq8") { (result) in
            if case .failure = result {
                XCTAssert(false, "getCar should succeed")
                return
            }
            do {
                if let car = try result.get() {
                    XCTAssert(car.make == "Honda")
                    XCTAssert(car.model == "CR-V")
                    XCTAssert(car.type == "SUV")
                    XCTAssert(car.color == "Silver")
                    XCTAssert(car.description == "Just traded is this nice low mileage 2018 Honda CR-V LX AWD in Lunar Silver over Gray Cloth")
                    XCTAssert(car.mileage == 30442)
                    XCTAssert(car.price == 18999)
                    XCTAssert(car.llat == 41.0)
                    XCTAssert(car.llong == -83.0)
                } else {
                    XCTAssert(false, "car should not be nil")
                }
            } catch {
                XCTAssert(false, "Failed getting car from success")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testGetCars() throws {
        let expectation = self.expectation(description: "servicecall")
        
        let filters = SearchFilters()

        service.getCars(filter: filters, llat: 41.0, llong: -83.0, count: 100, offset: 0) { (result) in
            if case .failure = result {
                XCTAssert(false, "getCars should succeed")
                return
            }
            do {
                if let cars = try result.get() {
                    XCTAssert(cars.count == 3, "Car count wrong")
                    let car0 = cars[0]
                    XCTAssert(car0.make == "Honda")
                    XCTAssert(car0.model == "CR-V")
                    XCTAssert(car0.type == "SUV")
                    XCTAssert(car0.color == "Silver")
                    XCTAssert(car0.description == "Just traded is this nice low mileage 2018 Honda CR-V LX AWD in Lunar Silver over Gray Cloth")
                    XCTAssert(car0.mileage == 30442)
                    XCTAssert(car0.price == 18999)
                    XCTAssert(car0.llat == 41.0)
                    XCTAssert(car0.llong == -83.0)
                    let car1 = cars[1]
                    XCTAssert(car1.make == "Ford")
                    XCTAssert(car1.model == "F150")
                    XCTAssert(car1.type == "Truck")
                    XCTAssert(car1.color == "Black")
                    XCTAssert(car1.description == "A real workhorse, brand new tires and just passed inspection.")
                    XCTAssert(car1.mileage == 162200)
                    XCTAssert(car1.price == 4500)
                    XCTAssert(car1.llat == 41.1)
                    XCTAssert(car1.llong == -83.1)
                } else {
                    XCTAssert(false, "cars should not be nil")
                }
            } catch {
                XCTAssert(false, "Failed getting cars from success")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testGetCarsPriceSeearch() throws {
        let expectation = self.expectation(description: "servicecall")
        
        let filters = SearchFilters()
         
        filters.price = SearchFilter(compare: .lessThan, value: 5000)

        service.getCars(filter: filters, llat: 41.0, llong: -83.0, count: 100, offset: 0) { (result) in
            if case .failure = result {
                XCTAssert(false, "getCars should succeed")
                return
            }
            do {
                if let cars = try result.get() {
                    XCTAssert(cars.count == 1, "Car count wrong")
                    let car0 = cars[0]
                    XCTAssert(car0.make == "Ford")
                    XCTAssert(car0.model == "F150")
                    XCTAssert(car0.type == "Truck")
                    XCTAssert(car0.color == "Black")
                    XCTAssert(car0.description == "A real workhorse, brand new tires and just passed inspection.")
                    XCTAssert(car0.mileage == 162200)
                    XCTAssert(car0.price == 4500)
                    XCTAssert(car0.llat == 41.1)
                    XCTAssert(car0.llong == -83.1)
                } else {
                    XCTAssert(false, "cars should not be nil")
                }
            } catch {
                XCTAssert(false, "Failed getting cars from success")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testGetCarsMileageSeearch() throws {
        let expectation = self.expectation(description: "servicecall")
        
        let filters = SearchFilters()
         
        filters.mileage = SearchFilter(compare: .greaterThan, value: 150000)

        service.getCars(filter: filters, llat: 41.0, llong: -83.0, count: 100, offset: 0) { (result) in
            if case .failure = result {
                XCTAssert(false, "getCars should succeed")
                return
            }
            do {
                if let cars = try result.get() {
                    XCTAssert(cars.count == 1, "Car count wrong")
                    let car0 = cars[0]
                    XCTAssert(car0.make == "Ford")
                    XCTAssert(car0.model == "F150")
                    XCTAssert(car0.type == "Truck")
                    XCTAssert(car0.color == "Black")
                    XCTAssert(car0.description == "A real workhorse, brand new tires and just passed inspection.")
                    XCTAssert(car0.mileage == 162200)
                    XCTAssert(car0.price == 4500)
                    XCTAssert(car0.llat == 41.1)
                    XCTAssert(car0.llong == -83.1)
                } else {
                    XCTAssert(false, "cars should not be nil")
                }
            } catch {
                XCTAssert(false, "Failed getting cars from success")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }

}

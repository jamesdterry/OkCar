//
//  CarModel.swift
//  OkCar
//
//  Created by James Terry on 7/19/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation

struct CarModel: Equatable {
    let storageId: String?
    let seller: UserModel
    let make: String
    let model: String
    let type: String
    let color: String
    let description: String
    let mileage: Int
    let price: Int
    let llat: Double
    let llong: Double
}

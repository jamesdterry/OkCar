//
//  SearchFilters.swift
//  OkCar
//
//  Created by James Terry on 7/19/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import Foundation

enum SearchCompare {
    case none
    case greaterThan
    case lessThan
}

struct SearchFilter {
    let compare: SearchCompare
    let value: Int
}

enum FilterCategory {
    case price
    case mileage
}

class SearchFilters {
    var price: SearchFilter = SearchFilter(compare: .none, value: 0)
    var mileage: SearchFilter = SearchFilter(compare: .none, value: 0)
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()

    private var areaFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter
    }()
    
    public func clear()
    {
        price = SearchFilter(compare: .none, value: 0)
        mileage = SearchFilter(compare: .none, value: 0)
    }
    
    public var isAnySet: Bool {
        return price.compare != .none ||
            mileage.compare != .none
    }
    
    public var describeMileage: String {
        switch mileage.compare {
            case .none:
                return ": Any"
            case .greaterThan:
                return " >= \(mileage.value)"
            case .lessThan:
                return " <= \(mileage.value)"
        }
    }
    
    public var describePrice: String {
        var valueString = "\(price.value)"
        if let formattedNumber = currencyFormatter.string(from: NSNumber(value:price.value)) {
            valueString = formattedNumber
        }
        
        switch price.compare {
            case .none:
                return ": Any"
            case .greaterThan:
                return " > \(valueString)"
            case .lessThan:
                return " < \(valueString)"
        }
    }
}

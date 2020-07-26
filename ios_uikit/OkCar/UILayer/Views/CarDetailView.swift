//
//  CarDetailView.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import PureLayout

class CarDetailView: UIView {
    let makeModelLabel = UILabel()
    let descriptionLabel = UILabel()
    let priceLabel = UILabel()

    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()

    init() {
        super.init(frame: UIScreen.main.bounds)
        
        let fieldsStack = UIStackView()
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 4
        addSubview(fieldsStack)
        
        fieldsStack.autoPinEdgesToSuperviewMargins()
        
        makeModelLabel.translatesAutoresizingMaskIntoConstraints = false
        makeModelLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        makeModelLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            makeModelLabel.textColor = .label
        } else {
            makeModelLabel.textColor = .labelColorPre13
        }
        makeModelLabel.textAlignment = .left
        fieldsStack.addArrangedSubview(makeModelLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            descriptionLabel.textColor = .label
        } else {
            descriptionLabel.textColor = .labelColorPre13
        }
        descriptionLabel.textAlignment = .left
        fieldsStack.addArrangedSubview(descriptionLabel)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.preferredFont(forTextStyle: .body)
        priceLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            priceLabel.textColor = .label
        } else {
            priceLabel.textColor = .labelColorPre13
        }
        priceLabel.textAlignment = .left
        fieldsStack.addArrangedSubview(priceLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ car: CarModel) {
        makeModelLabel.text = "\(car.make) \(car.model)"
        descriptionLabel.text = car.description
        
        var carPriceString = "$\(car.price)"
        if let formattedNumber = currencyFormatter.string(from: NSNumber(value: car.price)) {
            carPriceString = formattedNumber
        }

        priceLabel.text = carPriceString
    }
}

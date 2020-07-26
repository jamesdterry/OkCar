//
//  FilterView.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import PureLayout

protocol FilterViewDelegate: AnyObject {
    func clearFilters()
    func presentFilter(filterCategory: FilterCategory)
}

class FilterView: UIView {
    
    public weak var delegate: FilterViewDelegate?
    
    var filters: SearchFilters!
    
    let priceLabel = UILabel()
    let mileageLabel = UILabel()
    let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

    init() {
        super.init(frame: UIScreen.main.bounds)
        
        let fieldsStack = UIStackView()
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.axis = .horizontal
        fieldsStack.spacing = 4
        addSubview(fieldsStack)
        
        fieldsStack.autoPinEdgesToSuperviewMargins()

        let filterStack = UIStackView()
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        filterStack.axis = .vertical
        filterStack.spacing = 4
        fieldsStack.addArrangedSubview(filterStack)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        priceLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            priceLabel.textColor = .label
        } else {
            priceLabel.textColor = .labelColorPre13
        }
        priceLabel.textAlignment = .left
        filterStack.addArrangedSubview(priceLabel)
        priceLabel.isUserInteractionEnabled = true
        let priceTap = UITapGestureRecognizer(target: self, action: #selector(tapPriceFilter(_:)))
        priceLabel.addGestureRecognizer(priceTap)
        
        mileageLabel.translatesAutoresizingMaskIntoConstraints = false
        mileageLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        mileageLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            mileageLabel.textColor = .label
        } else {
            mileageLabel.textColor = .labelColorPre13
        }
        mileageLabel.textAlignment = .left
        filterStack.addArrangedSubview(mileageLabel)
        mileageLabel.isUserInteractionEnabled = true
        let mileageTap = UITapGestureRecognizer(target: self, action: #selector(tapMileageFilter(_:)))
        mileageLabel.addGestureRecognizer(mileageTap)

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.addArrangedSubview(clearButton)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.autoSetDimension(.width, toSize: 66)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        if #available(iOS 13.0, *) {
            clearButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            clearButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }
        clearButton.setTitleColor(.systemGray, for: .disabled)
        clearButton.layer.borderWidth = 1
        clearButton.layer.borderColor = UIColor.systemBlue.cgColor
        clearButton.layer.cornerRadius = 4
        clearButton.addTarget(self, action:#selector(clearButtonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        priceLabel.text = "Price\(filters.describePrice)"
        mileageLabel.text = "Mileage\(filters.describeMileage)"
        
        clearButton.isEnabled = filters.isAnySet
    }
    
    @objc func tapPriceFilter(_ tap: UITapGestureRecognizer) {
        delegate?.presentFilter(filterCategory: .price)
    }
        
    @objc func tapMileageFilter(_ tap: UITapGestureRecognizer) {
        delegate?.presentFilter(filterCategory: .mileage)
    }

    @objc func clearButtonTapped() {
        delegate?.clearFilters()
    }
}



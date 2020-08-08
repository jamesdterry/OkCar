//
//  CarDetailView.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import PureLayout
import Kingfisher

enum DetailSize {
    case small
    case large
}

class CarDetailView: UIView {
    let makeModelLabel = UILabel()
    let locationLabel = UILabel()
    let priceLabel = UILabel()
    let mileageLabel = UILabel()
    let mainUIImage = UIImageView()

    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()

    private lazy var mileageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        mainUIImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainUIImage)
        mainUIImage.autoPinEdge(toSuperviewMargin: .top)
        mainUIImage.autoPinEdge(toSuperviewMargin: .leading)
        mainUIImage.autoPinEdge(toSuperviewMargin: .trailing)
        mainUIImage.autoMatch(.height, to: .width, of: mainUIImage, withMultiplier: 2.0/3.0, relation: .equal)
        
        makeModelLabel.translatesAutoresizingMaskIntoConstraints = false
        makeModelLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        makeModelLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            makeModelLabel.textColor = .label
        } else {
            makeModelLabel.textColor = .labelColorPre13
        }
        makeModelLabel.textAlignment = .left
        addSubview(makeModelLabel)
        makeModelLabel.autoPinEdge(.top, to: .bottom, of: mainUIImage)
        makeModelLabel.autoPinEdge(toSuperviewMargin: .leading)
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.preferredFont(forTextStyle: .body)
        locationLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            locationLabel.textColor = .label
        } else {
            locationLabel.textColor = .labelColorPre13
        }
        locationLabel.textAlignment = .left
        addSubview(locationLabel)
        locationLabel.autoPinEdge(.top, to: .bottom, of: makeModelLabel)
        locationLabel.autoPinEdge(toSuperviewMargin: .leading)
        //descriptionLabel.autoPinEdge(toSuperviewMargin: .bottom)

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.preferredFont(forTextStyle: .body)
        priceLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            priceLabel.textColor = .label
        } else {
            priceLabel.textColor = .labelColorPre13
        }
        priceLabel.textAlignment = .right
        addSubview(priceLabel)
        priceLabel.autoPinEdge(.top, to: .bottom, of: mainUIImage)
        priceLabel.autoPinEdge(toSuperviewMargin: .trailing)
        
        makeModelLabel.autoAlignAxis(.horizontal, toSameAxisOf: priceLabel)
        
        mileageLabel.translatesAutoresizingMaskIntoConstraints = false
        mileageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        mileageLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            mileageLabel.textColor = .label
        } else {
            mileageLabel.textColor = .labelColorPre13
        }
        mileageLabel.textAlignment = .right
        addSubview(mileageLabel)
        mileageLabel.autoPinEdge(.top, to: .bottom, of: priceLabel)
        mileageLabel.autoPinEdge(toSuperviewMargin: .trailing)
        
        locationLabel.autoAlignAxis(.horizontal, toSameAxisOf: mileageLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ car: CarModel, size: DetailSize) {
        let url = URL(string: car.media[0])
        let processor = DownsamplingImageProcessor(size: self.bounds.size)
                     |> RoundCornerImageProcessor(cornerRadius: 20)
        mainUIImage.kf.indicatorType = .activity
        mainUIImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        
        let font = size == .large ? Style.sharedInstance.largeDetailFont() : Style.sharedInstance.smallDetailFont()
        makeModelLabel.font = font
        locationLabel.font = font
        priceLabel.font = font
        mileageLabel.font = font

        makeModelLabel.text = "\(car.make) \(car.model)"
        locationLabel.text = car.location
        
        var carPriceString = "$\(car.price)"
        if let formattedNumber = currencyFormatter.string(from: NSNumber(value: car.price)) {
            carPriceString = formattedNumber
        }

        priceLabel.text = carPriceString
        
        var carMileageString = "$\(car.mileage)"
        if let formattedNumber = mileageFormatter.string(from: NSNumber(value: car.mileage)) {
            carMileageString = formattedNumber
        }
        
        mileageLabel.text = carMileageString
    }
    
    static func detailTextHeight(size: DetailSize) -> CGFloat
    {
        var lineHeight: CGFloat = 0.0
        
        switch size {
        case .small:
            lineHeight = Style.sharedInstance.smallDetailLineHeight()
        case .large:
            lineHeight = Style.sharedInstance.largeDetailLineHeight()
        }
        
        return lineHeight * 2.0
    }
}

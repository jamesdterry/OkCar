//
//  CarCollectionViewCell.swift
//  OkCar
//
//  Created by James Terry on 8/4/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import PureLayout

class CarCollectionViewCell: UICollectionViewCell {

    let carDetailView = CarDetailView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        carDetailView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(carDetailView)
        carDetailView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ carViewModel: CarsViewModel, row: Int) {
        let car = carViewModel.cars[row]
        carDetailView.bind(car)
    }
}

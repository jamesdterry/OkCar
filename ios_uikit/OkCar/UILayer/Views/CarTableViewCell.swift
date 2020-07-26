//
//  CarTableViewCell.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import PureLayout

class CarTableViewCell: UITableViewCell {

    let carDetailView = CarDetailView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        self.selectionStyle = .none
        
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

//
//  FilterSheetViewController.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit

protocol FilterChangeHandler: AnyObject {
    func filterSet(filterCategory: FilterCategory, filter: SearchFilter)
}

fileprivate enum ModalTransitionType {
    case presentation
    case dismissal
}

fileprivate struct FilterValue {
    let display: String
    let value: Int
}

class FilterSheetViewController: UIViewController {
    private let cardView = UIView()
    private let dismissButton = UIButton()
    private let dismissTapView = UIView()
    private let pickerView = UIPickerView()

    fileprivate var currentModalTransitionType: ModalTransitionType? = nil

    fileprivate var overlayBackgroundColor: UIColor!
    
    private var filterCategory: FilterCategory
    private var startFilters: SearchFilters
    
    public weak var delegate: FilterChangeHandler?

    private var priceValues: [FilterValue] = []
    
    private var mileageValues: [FilterValue] = []
    
    init(filterCategory: FilterCategory, startFilters: SearchFilters) {
        self.filterCategory = filterCategory
        self.startFilters = startFilters
        
        super.init(nibName: nil, bundle: nil)

        self.transitioningDelegate = self
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        generateFilterChoices()

        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                overlayBackgroundColor = UIColor.white.withAlphaComponent(0.4)
            } else {
                overlayBackgroundColor = UIColor.black.withAlphaComponent(0.4)
            }
        } else {
            overlayBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
        self.view.backgroundColor = overlayBackgroundColor

        // Dismiss if background tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissButtonTapped))
        self.dismissTapView.addGestureRecognizer(tapGesture)
        self.view.addSubview(self.dismissTapView)
        self.dismissTapView.autoPinEdgesToSuperviewEdges()

        if #available(iOS 13.0, *) {
            cardView.backgroundColor = .systemBackground
        } else {
            cardView.backgroundColor = .systemBackgroundPre13
        }
        cardView.clipsToBounds = true
        view.addSubview(self.cardView)
        
        cardView.autoPinEdge(toSuperviewEdge: .leading, withInset: 0)
        cardView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0)
        cardView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        cardView.autoSetDimension(.height, toSize: 300)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
        } else {
            titleLabel.textColor = .labelColorPre13
        }
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        switch filterCategory {
            case .price:
                titleLabel.text = "Filter price by"
            case .mileage:
                titleLabel.text = "Filter mileage by"
        }
        cardView.addSubview(titleLabel)
        
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing)

        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(pickerView)
        pickerView.autoPinEdge(.top, to: .bottom, of: titleLabel)
        pickerView.autoPinEdge(toSuperviewEdge: .leading)
        pickerView.autoPinEdge(toSuperviewEdge: .trailing)

        dismissButton.setTitle("Filter", for: .normal)
        dismissButton.setTitleColor(self.view.tintColor, for: .normal)
        dismissButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        cardView.addSubview(self.dismissButton)

        dismissButton.autoPinEdge(.top, to: .bottom, of: pickerView)
        dismissButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
        dismissButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        dismissButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        dismissButton.autoSetDimension(.height, toSize: 50)
        
        // Set start value
        setStartPikcerValues()
    }
    
    @objc private func dismissButtonTapped() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func filterButtonTapped() {
        
        let compare:SearchCompare = pickerView.selectedRow(inComponent: 0) == 0 ? .greaterThan : .lessThan
        var value = 0
        let row = pickerView.selectedRow(inComponent: 1)
        switch filterCategory {
            case .price:
                value = priceValues[row].value
            case .mileage:
                value = mileageValues[row].value
        }

        let filter = SearchFilter(compare: compare, value: value)
        delegate?.filterSet(filterCategory: filterCategory, filter: filter)
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func setStartPikcerValues() {
        switch filterCategory {
            case .price:
                setStartPicker0(compare: startFilters.price.compare)
                setStartPicker1(valueList: priceValues, value: startFilters.price.value)
            case .mileage:
                setStartPicker0(compare: startFilters.mileage.compare)
                setStartPicker1(valueList: mileageValues, value: startFilters.mileage.value)
        }
    }
    
    private func setStartPicker0(compare: SearchCompare) {
        if compare == .greaterThan {
            pickerView.selectRow(0, inComponent: 0, animated: false)
        } else if compare == .lessThan {
            pickerView.selectRow(1, inComponent: 0, animated: false)
        }
    }
    
    private func setStartPicker1(valueList: [FilterValue], value: Int) {
        var row = 0
        for fvalue in valueList {
            if fvalue.value == value {
                pickerView.selectRow(row, inComponent: 1, animated: false)
                return
            }
            row += 1
        }
    }
}

extension FilterSheetViewController {

    private func generateFilterChoices()
    {
        let currencyNumberFormatter = NumberFormatter()
        currencyNumberFormatter.numberStyle = .currency
        currencyNumberFormatter.maximumFractionDigits = 0
        
        // Price By 100 to 2,000
        stride(from: 100, to: 2000, by: 100).forEach { i in
            if let formattedNumber = currencyNumberFormatter.string(from: NSNumber(value:i)) {
                priceValues.append(FilterValue(display: formattedNumber, value: i))
            }
        }
        
        // Price By 500 to 10,000
        stride(from: 2500, to: 10000, by: 500).forEach { i in
            if let formattedNumber = currencyNumberFormatter.string(from: NSNumber(value:i)) {
                priceValues.append(FilterValue(display: formattedNumber, value: i))
            }
        }
        
        // Price By 1,000 to 50,000
        stride(from: 11000, to: 50000, by: 1000).forEach { i in
            if let formattedNumber = currencyNumberFormatter.string(from: NSNumber(value:i)) {
                priceValues.append(FilterValue(display: formattedNumber, value: i))
            }
        }
        
        // Price By 2,000 to 100,000
        stride(from: 52000, to: 100000, by: 2000).forEach { i in
            if let formattedNumber = currencyNumberFormatter.string(from: NSNumber(value:i)) {
                priceValues.append(FilterValue(display: formattedNumber, value: i))
            }
        }
        
        // Price By 5,000 to 200,000
        stride(from: 105000, to: 200000, by: 5000).forEach { i in
            if let formattedNumber = currencyNumberFormatter.string(from: NSNumber(value:i)) {
                priceValues.append(FilterValue(display: formattedNumber, value: i))
            }
        }
        let mileageNumberFormatter = NumberFormatter()
        mileageNumberFormatter.numberStyle = .decimal
        
        // Mileage By 10,000 to 200,000
        stride(from: 10000, to: 200000, by: 10000).forEach { i in
            if let formattedNumber = mileageNumberFormatter.string(from: NSNumber(value:i)) {
                mileageValues.append(FilterValue(display: "\(formattedNumber) sq ft", value: i))
            }
        }

    }
}

extension FilterSheetViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = (presented == self) ? self : nil
        result?.currentModalTransitionType = .presentation
        return result
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = (dismissed == self) ? self : nil
        result?.currentModalTransitionType = .dismissal
        return result
    }
}

extension FilterSheetViewController: UIViewControllerAnimatedTransitioning {
    private var transitionDuration: TimeInterval {
        guard let transitionType = self.currentModalTransitionType else { fatalError() }
        switch transitionType {
        case .presentation:
            return 0.44
        case .dismissal:
            return 0.32
        }
    }

    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return transitionDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionType = self.currentModalTransitionType else { fatalError() }

        // Card is offscreen
        let cardOffscreenState = {
            let offscreenY = self.view.bounds.height - self.cardView.frame.minY + 20
            self.cardView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offscreenY)
            self.view.backgroundColor = .clear
        }

        // Card is onscreen.
        let presentedState = {
            self.cardView.transform = CGAffineTransform.identity
            self.view.backgroundColor = self.overlayBackgroundColor
        }

        // We want different animation timing, based on whether we're presenting or dismissing.
        let animator: UIViewPropertyAnimator
        switch transitionType {
            case .presentation:
                animator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.82)
            case .dismissal:
                animator = UIViewPropertyAnimator(duration: transitionDuration, curve: UIView.AnimationCurve.easeIn)
        }

        switch transitionType {
            case .presentation:
                let toView = transitionContext.view(forKey: .to)!
                UIView.performWithoutAnimation(cardOffscreenState)
                transitionContext.containerView.addSubview(toView)
                animator.addAnimations(presentedState)
            case .dismissal:
                animator.addAnimations(cardOffscreenState)
        }

        animator.addCompletion { (position) in
            assert(position == .end)
            transitionContext.completeTransition(true)
            self.currentModalTransitionType = nil
        }

        animator.startAnimation()
    }
}

extension FilterSheetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 2
        } else {
            switch filterCategory {
                case .price:
                    return priceValues.count
                case .mileage:
                    return mileageValues.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if component == 0 {
            if row == 0 {
                return "Greater than"
            } else {
                return "Less than"
            }
        } else {
            switch filterCategory {
                case .price:
                    return priceValues[row].display
                case .mileage:
                    return mileageValues[row].display
            }
        }
    }
    
}

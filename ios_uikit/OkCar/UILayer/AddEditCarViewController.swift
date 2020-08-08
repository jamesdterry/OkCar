//
//  AddEditCarViewController.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import MaterialTextField
import DLRadioButton
import PureLayout
import CoreLocation
import Contacts

class AddEditCarViewController: ScrollableContentViewController {
    typealias Container = CarServiceSingleton & ViewControllerFactory
    private let container: Container
    private let car: CarModel?
    
    typealias Completion = ()->Void
    var editCompletion: Completion?

    private lazy var carService = container.getCarService()

    private let makeTextField = MFTextField()
    private let modelTextField = MFTextField()
    private let descriptionTextField = MFTextField()
    private let priceTextField = MFTextField()
    private let powerSeatsRadioButton = DLRadioButton(frame: CGRect(x: 30, y: 200, width: 200, height: 30))
    private let sunroofRadioButton = DLRadioButton(frame: CGRect(x: 30, y: 200, width: 200, height: 30))
    private let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    private var saveButtonItem: UIBarButtonItem!

    private let activityIndicatorView = UIActivityIndicatorView()
    
    private var llat: Double?
    private var llong: Double?
    private var owner: UserModel?
    private var dateAdded: Date?

    init(container: Container, car: CarModel?) {
        self.container = container
        self.car = car
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButtonItem = UIBarButtonItem.init(
              title: "Cancel",
              style: .plain,
              target: self,
              action: #selector(cancelButtonTapped)
        )
        self.navigationItem.leftBarButtonItem = cancelButtonItem
        
        saveButtonItem = UIBarButtonItem.init(
              title: "Save",
              style: .plain,
              target: self,
              action: #selector(saveButtonTapped)
        )
        self.navigationItem.rightBarButtonItem = saveButtonItem
        
        makeTextField.translatesAutoresizingMaskIntoConstraints = false
        makeTextField.placeholder = "Make"
        makeTextField.accessibilityLabel = "Make"
        makeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldsStack.addArrangedSubview(makeTextField)
        
        modelTextField.translatesAutoresizingMaskIntoConstraints = false
        modelTextField.placeholder = "Model"
        modelTextField.accessibilityLabel = "Model"
        modelTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldsStack.addArrangedSubview(modelTextField)
        
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.placeholder = "Description"
        descriptionTextField.accessibilityLabel = "Description"
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldsStack.addArrangedSubview(descriptionTextField)
        
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.placeholder = "Price"
        priceTextField.accessibilityLabel = "Price"
        priceTextField.keyboardType = .decimalPad
        priceTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldsStack.addArrangedSubview(priceTextField)
        
        let radioButtonView = UIView()
        radioButtonView.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.addArrangedSubview(radioButtonView)
        
        powerSeatsRadioButton.translatesAutoresizingMaskIntoConstraints = false
        powerSeatsRadioButton.setTitle("Power Seats", for: .normal)
        if #available(iOS 13.0, *) {
            powerSeatsRadioButton.setTitleColor(.label, for: .normal)
            powerSeatsRadioButton.indicatorColor = .link
        } else {
            powerSeatsRadioButton.setTitleColor(.labelColorPre13, for: .normal)
            powerSeatsRadioButton.indicatorColor = .linkColorPre13
        }
        powerSeatsRadioButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        radioButtonView.addSubview(powerSeatsRadioButton)
        powerSeatsRadioButton.addTarget(self, action: #selector(radioButtonChanged(_:)), for: .touchUpInside);

        sunroofRadioButton.translatesAutoresizingMaskIntoConstraints = false
        sunroofRadioButton.setTitle("Rented", for: .normal)
        if #available(iOS 13.0, *) {
            sunroofRadioButton.setTitleColor(.label, for: .normal)
            sunroofRadioButton.indicatorColor = .link
        } else {
            sunroofRadioButton.setTitleColor(.labelColorPre13, for: .normal)
            sunroofRadioButton.indicatorColor = .linkColorPre13
        }
        sunroofRadioButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        radioButtonView.addSubview(sunroofRadioButton)
        sunroofRadioButton.addTarget(self, action: #selector(radioButtonChanged(_:)), for: .touchUpInside);

        powerSeatsRadioButton.autoSetDimension(.height, toSize: 44)
        powerSeatsRadioButton.autoSetDimension(.width, toSize: 120)
        powerSeatsRadioButton.autoPinEdge(toSuperviewEdge: .top)
        powerSeatsRadioButton.autoPinEdge(toSuperviewEdge: .bottom)
        powerSeatsRadioButton.autoPinEdge(toSuperviewEdge: .leading)

        sunroofRadioButton.autoSetDimension(.height, toSize: 44)
        sunroofRadioButton.autoSetDimension(.width, toSize: 120)
        sunroofRadioButton.autoPinEdge(toSuperviewEdge: .top)
        sunroofRadioButton.autoPinEdge(toSuperviewEdge: .bottom)
        sunroofRadioButton.autoPinEdge(.leading, to: .trailing, of: powerSeatsRadioButton)

        powerSeatsRadioButton.otherButtons = [sunroofRadioButton]
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.autoSetDimension(.height, toSize: 44)
        deleteButton.setTitleColor(UIColor.white, for: .normal)
        deleteButton.setTitleColor(UIColor.systemGray, for: .disabled)
        deleteButton.backgroundColor = UIColor.systemRed
        fieldsStack.addArrangedSubview(deleteButton)
        deleteButton.addTarget(self, action:#selector(deleteTapped), for: .touchUpInside)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .large
        }
        activityIndicatorView.autoCenterInSuperview()
        
        bind(car)
    }
    
    func bind(_ car: CarModel?)
    {
        if let car = car {
            makeTextField.text = car.make
            modelTextField.text = car.model
            descriptionTextField.text = car.description
            priceTextField.text = "\(car.price)"
            self.llat = car.llat
            self.llong = car.llong
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        if let car = self.car {
            saveCar(car)
        } else {
            addCar()
        }
    }
    
    func saveCar(_ car: CarModel)
    {
        // Extract from fields
        let editedCar = carWith(storageId: car.storageId)

        // Save
        activityIndicatorView.startAnimating()
        self.carService.updateCar(car: editedCar) { (result) in
            self.activityIndicatorView.stopAnimating()
            if case .failure = result {
                // Show Alert
                return
            }
            self.editCompletion?()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func addCar()
    {
        // Extract from fields
        let newCar = carWith(storageId: nil)
        
        // Add
        activityIndicatorView.startAnimating()
        self.carService.addCar(car: newCar) { (result) in
            self.activityIndicatorView.stopAnimating()
            
            if case .failure = result {
                // Show Alert
                return
            }
            
            self.editCompletion?()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func carWith(storageId: String?) -> CarModel
    {
        let make = makeTextField.text ?? ""
        let model = modelTextField.text ?? ""
        let description = descriptionTextField.text ?? ""
        let price = Int(priceTextField.text ?? "0") ?? 0
        
        return CarModel(storageId: storageId,
                        seller: carService.currentUser()!,
                        make: make,
                        model: model,
                        type: "",
                        color: "",
                        description: description,
                        mileage: 0,
                        price: price,
                        llat: 0,
                        llong: 0,
                        media: [])
                    
    }
    
    @objc func deleteTapped() {
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this car?", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.carService.deleteCar(car: self.car!) { (result) in
                if case .failure = result {
                    self.showErrorAlert(title: "Network Error", msg: "Error")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

}

extension AddEditCarViewController {
    
    private func validate()
    {
        if let make = makeTextField.text, !make.isEmpty,
           let model = makeTextField.text, !model.isEmpty,
           let description = descriptionTextField.text, !description.isEmpty,
           let price = priceTextField.text, !price.isEmpty {
            saveButtonItem.isEnabled = true
            return
        }
        
        saveButtonItem.isEnabled = false
    }
    
    @objc func radioButtonChanged(_ radioButton: UIButton) {
        validate()
    }
    
    private func numbersOnly(_ textField: UITextField) {
        if let text = textField.text {
            let numeric = text.filter("0123456789".contains)
            if text != numeric {
                textField.text = numeric
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == priceTextField {
            numbersOnly(textField)
        }
        
        validate()
    }
}

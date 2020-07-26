//
//  CreateAccountViewController.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import MaterialTextField
import PureLayout

class CreateAccountViewController: ScrollableContentViewController {
    typealias Container = CarServiceSingleton & ViewControllerFactory
    private let container: Container
    
    private lazy var carService = container.getCarService()

    private let emailTextField = MFTextField()
    private let passwordTextField = MFTextField()
    private let verifyPasswordTextField = MFTextField()
    private let createButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

    private let activityIndicatorView = UIActivityIndicatorView()
    
    init(container: Container) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
        } else {
            titleLabel.textColor = .labelColorPre13
        }
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.text = "Ok Car"
        fieldsStack.addArrangedSubview(titleLabel)

        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.accessibilityLabel = "Email"
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldsStack.addArrangedSubview(emailTextField)
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.adjustsFontForContentSizeCategory = true
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.accessibilityLabel = "Password"
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldsStack.addArrangedSubview(passwordTextField)
        
        verifyPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        verifyPasswordTextField.adjustsFontForContentSizeCategory = true
        verifyPasswordTextField.placeholder = "Verify password"
        verifyPasswordTextField.isSecureTextEntry = true
        verifyPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldsStack.addArrangedSubview(verifyPasswordTextField)
        
        let spacer1View = UIView()
        spacer1View.translatesAutoresizingMaskIntoConstraints = false
        spacer1View.autoSetDimension(.height, toSize: 22)
        fieldsStack.addArrangedSubview(spacer1View)

        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setTitle("Create new account", for: .normal)
        createButton.autoSetDimension(.height, toSize: 44)
        createButton.setTitleColor(.systemBlue, for: .normal)
        createButton.setTitleColor(.systemGray, for: .disabled)
        if #available(iOS 13.0, *) {
            createButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            createButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.systemBlue.cgColor
        createButton.layer.cornerRadius = 4

        fieldsStack.addArrangedSubview(createButton)
        createButton.addTarget(self, action:#selector(createButtonTapped), for: .touchUpInside)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .large
        }
        activityIndicatorView.autoCenterInSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        validate()
    }

    @objc func createButtonTapped() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        activityIndicatorView.startAnimating()
        
        carService.signup(email: email, password: password) { (result) in
            self.activityIndicatorView.stopAnimating()
            
            switch result {
            case .success(let user):
                if let _ = user {
                    let carsListViewController = self.container.makeCarsListViewController()
                    self.navigationController?.setViewControllers([carsListViewController], animated: true)
                } else {
                    assert(false, "Null error from signup")
                }
                break
            case .failure(let error):
                self.showErrorAlert(title: "Error", msg: error.localizedDescription)
                break
            }
        }

    }
    
}

extension CreateAccountViewController {
    
    func validEmail(_ email:String) -> Bool {

        let range = email.range(of: #"^.+?@.+?\..+$"#, options: .regularExpression)

        return range != nil
    }
    
    func validate()
    {
        if let email = emailTextField.text,
            let password = passwordTextField.text,
            let verifyPassword = verifyPasswordTextField.text {
            if !email.isEmpty && !password.isEmpty && !verifyPassword.isEmpty {
                if validEmail(email) && password == verifyPassword {
                    createButton.isEnabled = true
                    return
                }
            }
        }
        
        createButton.isEnabled = false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validate()
    }
}

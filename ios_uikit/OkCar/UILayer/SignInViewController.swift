//
//  SignInViewController.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import MaterialTextField
import PureLayout

class SignInViewController: ScrollableContentViewController {
    typealias Container = CarServiceSingleton & ViewControllerFactory & FilterSingleton
    private let container: Container
    
    private lazy var carService = container.getCarService()

    private var filters: SearchFilters

    private let emailTextField = MFTextField()
    private let passwordTextField = MFTextField()
    private let loginButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    private let forgotButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

    private let activityIndicatorView = UIActivityIndicatorView()

    init(container: Container) {
        self.container = container
        self.filters = container.getCurrentFilter()
        container.getCurrentFilter().clear()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
        } else {
            titleLabel.textColor = .labelColorPre13
        }
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "Ok Car"
        
        fieldsStack.addArrangedSubview(titleLabel)

        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.accessibilityLabel = "Email"
        fieldsStack.addArrangedSubview(emailTextField)
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.accessibilityLabel = "Password"
        fieldsStack.addArrangedSubview(passwordTextField)
        
        let spacer1View = UIView()
        spacer1View.translatesAutoresizingMaskIntoConstraints = false
        spacer1View.autoSetDimension(.height, toSize: 22)
        fieldsStack.addArrangedSubview(spacer1View)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Login", for: .normal)
        loginButton.autoSetDimension(.height, toSize: 44)

        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.setTitleColor(.systemGray, for: .disabled)
        if #available(iOS 13.0, *) {
            loginButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            loginButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.systemBlue.cgColor
        loginButton.layer.cornerRadius = 4

        fieldsStack.addArrangedSubview(loginButton)
        loginButton.addTarget(self, action:#selector(loginButtonTapped), for: .touchUpInside)

        forgotButton.translatesAutoresizingMaskIntoConstraints = false
        forgotButton.setTitle("Forgot Password?", for: .normal)
        forgotButton.autoSetDimension(.height, toSize: 44)
        forgotButton.setTitleColor(.systemBlue, for: .normal)
        forgotButton.setTitleColor(.systemGray, for: .disabled)
        if #available(iOS 13.0, *) {
            forgotButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            forgotButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }

        fieldsStack.addArrangedSubview(forgotButton)
        forgotButton.addTarget(self, action:#selector(forgotButtonTapped), for: .touchUpInside)

        let spacer2View = UIView()
        spacer2View.translatesAutoresizingMaskIntoConstraints = false
        spacer2View.autoSetDimension(.height, toSize: 22)
        fieldsStack.addArrangedSubview(spacer2View)

        let newAccountButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        newAccountButton.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.addArrangedSubview(newAccountButton)
        newAccountButton.setTitle("Create new account", for: .normal)
        newAccountButton.autoSetDimension(.height, toSize: 36)
        newAccountButton.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 50, relation: .equal)
        newAccountButton.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -50, relation: .equal)
        newAccountButton.setTitleColor(.systemBlue, for: .normal)
        if #available(iOS 13.0, *) {
            newAccountButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            newAccountButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }
        newAccountButton.layer.borderWidth = 1
        newAccountButton.layer.borderColor = UIColor.systemBlue.cgColor
        newAccountButton.layer.cornerRadius = 4
        newAccountButton.addTarget(self, action:#selector(newAccountButtonTapped), for: .touchUpInside)
        
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
    
    
    @objc func forgotButtonTapped() {
        if let email = emailTextField.text {
            activityIndicatorView.startAnimating()
            
            carService.forgotPassword(email: email) { (result) in
                self.activityIndicatorView.stopAnimating()
                self.showErrorAlert(title: "Message:", msg: "Password reset email sent.")
            }
        }
    }
        
    @objc func loginButtonTapped() {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
        
            activityIndicatorView.startAnimating()
            
            carService.login(email: email, password: password) { (result) in
                self.activityIndicatorView.stopAnimating()
                
                switch result {
                case .success(let user):
                    if user != nil {
                        self.container.switchToTabController()
                    } else {
                        assert(false, "Null error from login")
                    }
                    break
                case .failure(let error):
                    if error == .invalid {
                        self.showErrorAlert(title: "Error", msg: "Email or password incorrect")
                    } else {
                        self.showErrorAlert(title: "Error", msg: error.localizedDescription)
                    }
                    break
                }
                
            }
        }
        

    }

    @objc func newAccountButtonTapped() {
        let createAccountViewController = container.makeCreateAccountViewController()
        self.navigationController?.pushViewController(createAccountViewController, animated: true)
    }
    
}

extension SignInViewController {
    func validEmail(_ email:String) -> Bool {

        let range = email.range(of: #"^.+?@.+?\..+$"#, options: .regularExpression)

        return range != nil
    }

    func validateForget()
    {
        if let email = emailTextField.text {
            if validEmail(email) {
                forgotButton.isEnabled = true
                return
            }
        }
        
        forgotButton.isEnabled = false
    }
    
    func validateLogin()
    {
        if let email = emailTextField.text,
            let password = passwordTextField.text {
            if validEmail(email) && !password.isEmpty {
                loginButton.isEnabled = true
                return
            }
        }
        
        loginButton.isEnabled = false
    }
    
    func validate()
    {
        validateLogin()
        validateForget()
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        validate()
    }
}

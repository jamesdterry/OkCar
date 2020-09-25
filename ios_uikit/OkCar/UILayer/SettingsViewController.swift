//
//  SettingsViewController.swift
//  OkCar
//
//  Created by James Terry on 9/1/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import MaterialTextField
import PureLayout

class SettingsViewController: ScrollableContentViewController {
    typealias Container = CarServiceSingleton & ViewControllerFactory
    private let container: Container

    private lazy var carService = container.getCarService()
    
    private let accountLabel = UILabel()
    private let passwordTextField = MFTextField()
    private let verifyPasswordTextField = MFTextField()
    private let updatePasswordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    private let logoutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    
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

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .systemBackgroundPre13
        }
        
        if title == nil {
            title = "Settings"
        }
        
        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        accountLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        accountLabel.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            accountLabel.textColor = .label
        } else {
            accountLabel.textColor = .labelColorPre13
        }
        accountLabel.numberOfLines = 1
        accountLabel.textAlignment = .center
        fieldsStack.addArrangedSubview(accountLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        accountLabel.text = ""
        if let user = carService.currentUser() {
            accountLabel.text = user.email
        }
        
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

        updatePasswordButton.translatesAutoresizingMaskIntoConstraints = false
        updatePasswordButton.setTitle("Update password", for: .normal)
        updatePasswordButton.autoSetDimension(.height, toSize: 44)
        updatePasswordButton.setTitleColor(.systemBlue, for: .normal)
        updatePasswordButton.setTitleColor(.systemGray, for: .disabled)
        if #available(iOS 13.0, *) {
            updatePasswordButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            updatePasswordButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }
        updatePasswordButton.layer.borderWidth = 1
        updatePasswordButton.layer.borderColor = UIColor.systemBlue.cgColor
        updatePasswordButton.layer.cornerRadius = 4

        fieldsStack.addArrangedSubview(updatePasswordButton)
        updatePasswordButton.addTarget(self, action:#selector(updatePasswordButtonTapped), for: .touchUpInside)
        
        let spacer2View = UIView()
        spacer2View.translatesAutoresizingMaskIntoConstraints = false
        spacer2View.autoSetDimension(.height, toSize: 22)
        fieldsStack.addArrangedSubview(spacer2View)

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.addArrangedSubview(logoutButton)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.autoSetDimension(.height, toSize: 44)
        logoutButton.setTitleColor(.systemBlue, for: .normal)
        logoutButton.setTitleColor(.systemGray, for: .disabled)
        if #available(iOS 13.0, *) {
            logoutButton.setTitleColor(.secondaryLabel, for: .highlighted)
        } else {
            logoutButton.setTitleColor(.secondaryLabelColorPre13, for: .highlighted)
        }
        logoutButton.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 50, relation: .equal)
        logoutButton.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -50, relation: .equal)
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.systemBlue.cgColor
        logoutButton.layer.cornerRadius = 4
        
        logoutButton.addTarget(self, action:#selector(logoutButtonTapped), for: .touchUpInside)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .large
        }
        activityIndicatorView.autoCenterInSuperview()

    }
    
    @objc func logoutButtonTapped() {
        carService.logout()
        
        self.container.switchToLoginController()
    }
    
    @objc func updatePasswordButtonTapped() {
        guard let password = passwordTextField.text else { return }
        
        activityIndicatorView.startAnimating()
        
        carService.updatePassword(password: password) { (result) in
            self.activityIndicatorView.stopAnimating()
            
            switch result {
            case .success:
                self.showMsgAlert(title: "Complete", msg: "Password updated")
                break
            case .failure(let error):
                self.showErrorAlert(title: "Error", msg: error.localizedDescription)
                break
            }
        }

    }

}

extension SettingsViewController {
    
    func validate()
    {
        if let password = passwordTextField.text,
           let verifyPassword = verifyPasswordTextField.text {
            if !password.isEmpty && !verifyPassword.isEmpty {
                if password == verifyPassword {
                    updatePasswordButton.isEnabled = true
                    return
                }
            }
        }
        
        updatePasswordButton.isEnabled = false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validate()
    }
}

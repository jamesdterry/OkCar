//
//  ScrollableContentViewController.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import MaterialTextField
import DLRadioButton
import PureLayout

class ScrollableContentViewController: UIViewController {
    let scrollContainer = UIScrollView()
    let fieldsStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
                
        scrollContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollContainer.showsVerticalScrollIndicator = true
        scrollContainer.isDirectionalLockEnabled = true
        self.view.addSubview(scrollContainer)
        scrollContainer.autoPinEdgesToSuperviewEdges()
        
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        scrollContainer.addSubview(borderView)
        borderView.autoMatch(.width, to: .width, of: self.view, withMultiplier: 1, relation: .equal)
        borderView.autoPinEdgesToSuperviewEdges()

        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 4
        borderView.addSubview(fieldsStack)
        
        fieldsStack.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        fieldsStack.autoPinEdge(toSuperviewEdge: .left, withInset: 8)
        fieldsStack.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        fieldsStack.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)

    }
        
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollContainer.contentInset = .zero
        } else {
            scrollContainer.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
    }
}

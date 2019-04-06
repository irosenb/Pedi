//
//  NameViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/5/19.
//  Copyright © 2019 Pedi Inc. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {
  var password: String?
  var email: String? 
  let firstName = PDTextField()
  let lastName = PDTextField()
  let label = UILabel()
  let continueButton = UIButton()
  var continueBottomAnchor: NSLayoutConstraint?
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    navigationController?.navigationBar.isHidden = true
    
    addViews()
    addConstraints()
    
    NotificationCenter.default.addObserver(self, selector: #selector(EmailSignupViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    label.text = "What's your name?"
    label.textColor = Styles.Colors.purple
    label.sizeToFit()
    view.addSubview(label)
    
    firstName.translatesAutoresizingMaskIntoConstraints = false
    firstName.placeholder = "First name"
    view.addSubview(firstName)
    
    lastName.translatesAutoresizingMaskIntoConstraints = false
    lastName.placeholder = "Last name"
    view.addSubview(lastName)
    
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    continueButton.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
    continueButton.setTitle("Continue", for: .normal)
    continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    continueButton.isEnabled = true
    continueButton.backgroundColor = Styles.Colors.purple
    view.addSubview(continueButton)
  }
  
  func addConstraints() {
    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
    label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
    
    firstName.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 43).isActive = true
    firstName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
    firstName.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    firstName.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    lastName.topAnchor.constraint(equalTo: firstName.bottomAnchor, constant: 20).isActive = true
    lastName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
    lastName.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    lastName.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
    continueBottomAnchor?.isActive = true
    
    continueButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
  }
  
  @objc func nextScreen() {
    
  }
  
  @objc func keyboardWillShow(notification: Notification) {
    let frame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    continueBottomAnchor?.constant = -frame.height
    view.setNeedsLayout()
  }

}

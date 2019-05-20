//
//  PasswordViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/4/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {
  var email: String?
  var isDriver: Bool?
  let password = PDTextField()
  let label = UILabel()
  let continueButton = UIButton()
  var continueBottomAnchor: NSLayoutConstraint?
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    addViews()
    addConstraints()
    
    NotificationCenter.default.addObserver(self, selector: #selector(PasswordViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    password.translatesAutoresizingMaskIntoConstraints = false
    password.isSecureTextEntry = true
    password.placeholder = "Make it secure"
    password.autocorrectionType = .no
    view.addSubview(password)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Create your password"
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    view.addSubview(label)
    
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
    
    password.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 43).isActive = true
    password.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
    password.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    password.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
    continueBottomAnchor?.isActive = true
    
    continueButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
  }
  
  @objc func keyboardWillShow(notification: Notification) {
    continueBottomAnchor?.isActive = false
    let frame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    continueBottomAnchor?.constant = -frame.height
    continueBottomAnchor?.isActive = true
    view.setNeedsLayout()
  }
  
  @objc func nextScreen() {
    let name = NameViewController()
    
    name.password = password.text
    name.email = email
    name.isDriver = isDriver
    navigationController?.pushViewController(name, animated: true)
  }
}

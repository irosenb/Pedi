//
//  SSNViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 5/3/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class SSNViewController: UIViewController {
  var password: String?
  var email: String?
  var isDriver: Bool?
  let ssn = PDTextField()
  let label = UILabel()
  let loader = UIActivityIndicatorView()
  let continueButton = UIButton()
  var continueBottomAnchor: NSLayoutConstraint?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addViews()
    addConstraints()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    label.text = "Last 4 digits of your SSN?"
    label.sizeToFit()
    view.addSubview(label)
    
    ssn.translatesAutoresizingMaskIntoConstraints = false
    ssn.placeholder = "We need this for verification purposes"
    view.addSubview(ssn)
    
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    continueButton.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
    continueButton.setTitle("Continue", for: .normal)
    continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    continueButton.isEnabled = true
    continueButton.backgroundColor = Styles.Colors.purple
    view.addSubview(continueButton)
    
    loader.translatesAutoresizingMaskIntoConstraints = false
    loader.hidesWhenStopped = true
    view.addSubview(loader)
  }
  
  func addConstraints() {
    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
    label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
    
    ssn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 43).isActive = true
    ssn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
    ssn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    ssn.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
    continueBottomAnchor?.isActive = true
    
    continueButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    
    loader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor, constant: 0).isActive = true
    loader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor, constant: 0).isActive = true
  }

  @objc func keyboardWillShow(notification: Notification) {
    let frame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    continueBottomAnchor?.constant = -frame.height
    continueBottomAnchor?.isActive = true
    view.setNeedsLayout()
  }

  
  @objc func nextScreen() {
    
  }

}

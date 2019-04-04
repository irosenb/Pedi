//
//  ViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/03/19.
//  Copyright © 2019 Pedi Inc. All rights reserved.
//

import UIKit

class EmailSignupViewController: UIViewController {
  let email = PDTextField()
  let label = UILabel()
  let continueButton = UIButton()
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
 
    navigationController?.navigationBar.isHidden = true
    
    addViews() 
    addConstraints()

    
  }

  func addViews() {
    email.translatesAutoresizingMaskIntoConstraints = false
    email.placeholder = "Email"
    email.keyboardType = .emailAddress
    email.autocapitalizationType = .none
    email.autocorrectionType = .no
    view.addSubview(email)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    label.text = "What's your email?"
    label.sizeToFit()
    view.addSubview(label)
    
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    continueButton.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
    continueButton.setTitle("Continue", for: .normal)
    continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    continueButton.backgroundColor = Styles.Colors.purple
    view.addSubview(continueButton)
  }
  
  func addConstraints() {
    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
    label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
    
    email.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 43).isActive = true
    email.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
    email.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    email.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    continueButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
  }
  
  @objc func nextScreen() {
    
  }
}

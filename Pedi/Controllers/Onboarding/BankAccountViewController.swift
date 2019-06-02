//
//  BankAccountViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 5/13/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class BankAccountViewController: UIViewController {
  let label = UILabel()
  var isDriver: Bool?
  var ssn: String?
  var dob: Date?
  let loader = UIActivityIndicatorView()
  let continueButton = UIButton()
  var continueBottomAnchor: NSLayoutConstraint?
  let routingField = PDTextField()
  let accountField = PDTextField()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    addViews()
    addConstraints()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
    label.text = "What's your checking account?"
    label.sizeToFit()
    view.addSubview(label)
    
    routingField.translatesAutoresizingMaskIntoConstraints = false
    routingField.placeholder = "Routing number"
    routingField.keyboardType = .numberPad
    view.addSubview(routingField)
    
    accountField.translatesAutoresizingMaskIntoConstraints = false
    accountField.placeholder = "Account number"
    accountField.keyboardType = .numberPad
    view.addSubview(accountField)
    
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
    
    routingField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 43).isActive = true
    routingField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
    routingField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    routingField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    accountField.topAnchor.constraint(equalTo: routingField.bottomAnchor, constant: 20).isActive = true
    accountField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
    accountField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    accountField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
    continueBottomAnchor?.isActive = true
    
    continueButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    
    loader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor, constant: 0).isActive = true
    loader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor, constant: 0).isActive = true
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
    guard let birthday = dob else { return }
    guard let socialSecurity = ssn else { return }
    
    let day = Calendar.current.component(.day, from: birthday)
    let month = Calendar.current.component(.month, from: birthday)
    let year = Calendar.current.component(.year, from: birthday)
    
    guard let account = accountField.text else { return }
    guard let routing = routingField.text else { return }
    
    continueButton.setTitle("", for: .normal)
    loader.startAnimating()
    
    PDDriver.setStripe(day: day, month: month, year: year, ssn: socialSecurity, routing: routing, account: account) { (data) in
      self.loader.stopAnimating()
      let driver = DriverViewController()
      let nav = UINavigationController(rootViewController: driver)
      self.present(nav, animated: true, completion: nil)
    }
  }
  
  func showError(error: String) {
    
  }

}

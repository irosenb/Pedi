//
//  BirthdayViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 5/3/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {
  let label = UILabel()
  var isDriver: Bool?
  var ssn: String?
  let dob = UIDatePicker()
  let loader = UIActivityIndicatorView()
  let continueButton = UIButton()
  var continueBottomAnchor: NSLayoutConstraint?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    addViews()
    addConstraints()
    // Do any additional setup after loading the view.
  }

  func addViews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    label.text = "Date of birth?"
    label.sizeToFit()
    view.addSubview(label)
    
    dob.translatesAutoresizingMaskIntoConstraints = false
    dob.datePickerMode = .date
    view.addSubview(dob)
    
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
    
    dob.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 43).isActive = true
    dob.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
    dob.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    dob.heightAnchor.constraint(equalToConstant: 200).isActive = true
    
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
    let day = Calendar.current.component(.day, from: dob.date)
    let month = Calendar.current.component(.month, from: dob.date)
    let year = Calendar.current.component(.year, from: dob.date)
    
    PDDriver.setStripe(day: day, month: month, year: year, ssn: ssn!) { (data) in
      let driver = DriverViewController()
      let nav = UINavigationController(rootViewController: driver)
      self.present(nav, animated: true, completion: nil)
    }
  }
}

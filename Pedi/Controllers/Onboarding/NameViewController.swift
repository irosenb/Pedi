//
//  NameViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/5/19.
//  Copyright © 2019 Pedi Inc. All rights reserved.
//

import UIKit
import Alamofire

class NameViewController: UIViewController {
  var password: String?
  var email: String?
  var isDriver: Bool?
  let firstName = PDTextField()
  let lastName = PDTextField()
  let label = UILabel()
  let loader = UIActivityIndicatorView()
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
    
    loader.translatesAutoresizingMaskIntoConstraints = false
    loader.hidesWhenStopped = true
    view.addSubview(loader)
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
    
    loader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor, constant: 0).isActive = true
    loader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor, constant: 0).isActive = true
    
  }
  
  @objc func nextScreen() {
    continueButton.setTitle("", for: .normal)
    loader.startAnimating()
    
    if let first = firstName.text, let last = lastName.text, let pwd = password, let mail = email, let driver = isDriver {
      if driver {
        PDDriver.create(firstName: first, lastName: last, password: pwd, email: mail) { (data) in
          guard let results = data else { return }
          self.saveObjectsAndPushController(data: results)
        }
      } else {
        PDUser.create(firstName: first, lastName: last, password: pwd, email: mail) { (data) in
          self.loader.stopAnimating()
          guard let results = data else { return }
          self.saveObjectsAndPushController(data: results)
        }
      }
    }
  }
  
  func saveObjectsAndPushController(data: [String: Any]) {
    
    guard let token = data["auth_token"] as? String else { return }
    PDPersonData.setAuthToken(token)
    
    guard let isDriver = data["is_driver"] as? Bool else { return }
    PDPersonData.setIsDriver(isDriver)
    
    guard let userId = data["user_id"] as? String else { return }
    PDPersonData.setUserId(userId)
    
    if let driverId = data["driver_id"] as? String {
      PDPersonData.setDriverId(driverId)
    }
    
    var controller: UIViewController?
    
    if isDriver {
      controller = DriverViewController()
    } else {
      controller = RequestRideViewController()
    }
    
    let nav = UINavigationController(rootViewController: controller!)
    
    DispatchQueue.main.async {
      self.present(nav, animated: true, completion: nil)
    }
  }
  
  @objc func keyboardWillShow(notification: Notification) {
    let frame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    continueBottomAnchor?.constant = -frame.height
    continueBottomAnchor?.isActive = true
    view.setNeedsLayout()
  }

}

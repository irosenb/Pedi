//
//  NameViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/5/19.
//  Copyright © 2019 Pedi Inc. All rights reserved.
//

import UIKit
import Alamofire
import Stripe

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
  var terms = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    navigationController?.navigationBar.isHidden = true
    
    addViews()
    addConstraints()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    label.text = "What's your name?"
    label.sizeToFit()
    view.addSubview(label)
    
    if let driver = isDriver, driver {
      label.text = "What's your legal name?"
    }
    
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
    
    terms.translatesAutoresizingMaskIntoConstraints = false
    terms.text = "By continuing, you agree to the Terms of Service and Privacy Policy."
    view.addSubview(terms)
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
    
    terms.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20).isActive = true
    terms.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    terms.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
    terms.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
    
    guard let userId = data["user_id"] as? Int else { return }
    PDPersonData.setUserId(userId)
    
    if let driverId = data["driver_id"] as? Int {
      PDPersonData.setDriverId(driverId)
    }
    
    var controller: UIViewController?
    
    if isDriver {
      controller = SSNViewController()
    } else {
      let addCardController = STPAddCardViewController()
      addCardController.delegate = self
      navigationController?.navigationBar.isHidden = false
      self.navigationController?.pushViewController(addCardController, animated: true)
      return
    }
    
    DispatchQueue.main.async {
      self.navigationController?.pushViewController(controller!, animated: true)
    }
  }
  
  @objc func keyboardWillShow(notification: Notification) {
    continueBottomAnchor?.isActive = false
    let frame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    continueBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    continueBottomAnchor?.constant = -frame.height
    continueBottomAnchor?.isActive = true
    view.setNeedsLayout()
  }

}

extension NameViewController: STPAddCardViewControllerDelegate {
  func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
    navigationController?.popViewController(animated: true)
    self.navigationController?.isNavigationBarHidden = true 
  }
  
  func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
    PDUser.saveCreditCard(token: token.tokenId) { (data) in
      guard let results = data else {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.isNavigationBarHidden = true
        return
      }
      
      let requestRide = RequestRideViewController()
      let nav = UINavigationController(rootViewController: requestRide)
      self.present(nav, animated: true, completion: nil)
    }
  }
}

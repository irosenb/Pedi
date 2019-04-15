//
//  DriverOrUserViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/14/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class DriverOrUserViewController: UIViewController {
  let toggle = UISwitch()
  let label = UILabel()
  let driverButton = UIButton()
  let userButton = UIButton()
  
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
    label.text = "Driver or User?"
    view.addSubview(label)
    
    driverButton.addTarget(self, action: #selector(selectDriver), for: .touchUpInside)
    driverButton.setTitle("Driver", for: .normal)
    driverButton.backgroundColor = Styles.Colors.purple
    driverButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(driverButton)
    
    userButton.translatesAutoresizingMaskIntoConstraints = false
    userButton.setTitle("User", for: .normal)
    userButton.backgroundColor = Styles.Colors.purple
    userButton.addTarget(self, action: #selector(selectUser), for: .touchUpInside)
    view.addSubview(userButton)
    
  }

  
  func addConstraints() {
    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    label.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
    driverButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -30).isActive = true
    driverButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    driverButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    
    userButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 30).isActive = true
    userButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    userButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
  }
  
  @objc func selectDriver() {
    let controller = EmailSignupViewController()
    controller.isDriver = true
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc func selectUser() {
    let controller = EmailSignupViewController()
    controller.isDriver = false
    navigationController?.pushViewController(controller, animated: true)
  }
}

//
//  LandingViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/14/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
  let logo = UIImageView()
  let titleView = UILabel()
  let login = UIButton()
  let signup = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = true
    view.backgroundColor = Styles.Colors.purple
    
    addViews()
    addConstraints()
    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    logo.translatesAutoresizingMaskIntoConstraints = false
    logo.image = UIImage(named: "AppIcon")
    view.addSubview(logo)
    
    titleView.translatesAutoresizingMaskIntoConstraints = false
    titleView.text = "Pedi"
    view.addSubview(titleView)
    
    login.translatesAutoresizingMaskIntoConstraints = false
    login.setTitle("Login", for: .normal)
    login.layer.borderColor = UIColor.white.cgColor
    login.layer.borderWidth = 4
    login.addTarget(self, action: #selector(logIn), for: .touchUpInside)
    view.addSubview(login)
    
    signup.translatesAutoresizingMaskIntoConstraints = false
    signup.setTitle("Signup", for: .normal)
    signup.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    signup.layer.borderColor = UIColor.white.cgColor
    signup.layer.borderWidth = 4
    view.addSubview(signup)
    
  }
  
  func addConstraints() {
    logo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 144).isActive = true
    logo.widthAnchor.constraint(equalToConstant: 100).isActive = true
    logo.heightAnchor.constraint(equalToConstant: 100).isActive = true
    
    titleView.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 0).isActive = true
    titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    
    signup.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24).isActive = true
    signup.heightAnchor.constraint(equalToConstant: 60).isActive = true
    signup.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    signup.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 15).isActive = true
    
    login.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24).isActive = true
    login.heightAnchor.constraint(equalToConstant: 60).isActive = true
    login.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    login.bottomAnchor.constraint(equalTo: signup.topAnchor, constant: 15).isActive = true
    
    
  }
  
  @objc func signUp() {
    let controller = DriverOrUserViewController()
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc func logIn() {
    
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

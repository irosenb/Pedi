//
//  DriverViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/11/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class DriverViewController: UIViewController {
  let toggle = UISwitch()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    toggle.translatesAutoresizingMaskIntoConstraints = false
    toggle.addTarget(self, action: #selector(toggleDriving), for: .valueChanged)
    toggle.onTintColor = Styles.Colors.purple
//    navigationController?.navigationBar.set
    
  }
  
  func addConstraints() {
    
  }
  
  @objc func toggleDriving() {
    
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

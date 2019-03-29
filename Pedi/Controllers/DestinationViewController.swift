//
//  DestinationViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/29/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
class DestinationViewController: UIViewController {
  let startTextField = PDSearchField()
  let destinationTextField = PDSearchField()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addViews()
    addConstraints()
    
    view.backgroundColor = .white
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DestinationViewController.dismissVC))
      // Do any additional setup after loading the view.
  }
  
  func addViews() {
    startTextField.translatesAutoresizingMaskIntoConstraints = false
    startTextField.placeholder = "Current Location"
    view.addSubview(startTextField)
    
    destinationTextField.translatesAutoresizingMaskIntoConstraints = false
    destinationTextField.becomeFirstResponder()
    view.addSubview(destinationTextField)
  }
  
  func addConstraints() {
    let startTop = NSLayoutConstraint(item: startTextField, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 67)
    let searchWidth = NSLayoutConstraint(item: startTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
    let searchHeight = NSLayoutConstraint(item: startTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
    let searchCenterX = NSLayoutConstraint(item: startTextField, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    view.addConstraints([startTop, searchWidth, searchHeight, searchCenterX])
    
    let destinationTop = NSLayoutConstraint(item: destinationTextField, attribute: .top, relatedBy: .equal, toItem: startTextField, attribute: .bottom, multiplier: 1, constant: -5)
    let destinationWidth = NSLayoutConstraint(item: destinationTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
    let destinationHeight = NSLayoutConstraint(item: destinationTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
    let destinationCenterX = NSLayoutConstraint(item: destinationTextField, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    view.addConstraints([destinationTop, destinationHeight, destinationWidth, destinationCenterX])
  }

  
  @objc func dismissVC() {
    self.dismiss(animated: true, completion: nil)
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

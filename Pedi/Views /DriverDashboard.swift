//
//  DriverDashboard.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/15/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class DriverDashboard: UIView {
  let toggle = UISwitch()
  let cancel = UIButton()
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addViews()
    setConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func addViews() {
    toggle.translatesAutoresizingMaskIntoConstraints = false
    toggle.onTintColor = Styles.Colors.purple
    addSubview(toggle)
    
    cancel.translatesAutoresizingMaskIntoConstraints = false
    cancel.setTitle("X", for: .normal)
    cancel.backgroundColor = Styles.Colors.darkPurple
    cancel.isHidden = true
    addSubview(cancel)
  }
  
  func setConstraints() {
    toggle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
    toggle.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
    
    cancel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
    cancel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    cancel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    cancel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
    
  }
}

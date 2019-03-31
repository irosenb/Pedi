//
//  DestintationBar.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/30/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class DestinationBar: UIView {
  let start = UILabel()
  let destination = UILabel()
  let arrow = UIImageView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    layer.cornerRadius = 4
    backgroundColor = Styles.Colors.darkPurple
    
    addViews()
    constrain()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addViews() {
    start.translatesAutoresizingMaskIntoConstraints = false
    start.textColor = .white
    addSubview(start)
    
    destination.translatesAutoresizingMaskIntoConstraints = false
    destination.textColor = .white
    addSubview(destination)
  }
  
  func constrain() {
    start.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
    start.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
    start.widthAnchor.constraint(equalToConstant: 150).isActive = true
    
    destination.widthAnchor.constraint(equalToConstant: 150).isActive = true
    destination.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
    destination.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
  }
}

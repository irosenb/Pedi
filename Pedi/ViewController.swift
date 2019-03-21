//
//  ViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/20/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let searchField = PDSearchField()
  var searchBottom: NSLayoutConstraint?
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    
    addViews()
    addConstraints()
  }
  
  func addViews() {
    searchField.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(searchField)
    
    
  }
  
  func addConstraints() {
    searchBottom = NSLayoutConstraint(item: searchField, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -32)
    let searchWidth = NSLayoutConstraint(item: searchField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
    let searchHeight = NSLayoutConstraint(item: searchField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
    view.addConstraints([searchBottom!, searchWidth, searchHeight])
  }

}


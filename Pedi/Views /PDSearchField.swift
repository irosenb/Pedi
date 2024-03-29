//
//  PDSearchField.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/20/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class PDTextField: UITextField {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    placeholder = "Where to?"
    attributedPlaceholder = NSAttributedString(string: "Where to?", attributes: [NSAttributedString.Key.foregroundColor: Styles.Colors.purple])
    backgroundColor = Styles.Colors.lightPurple
    
    layer.borderColor = Styles.Colors.purple.cgColor
    layer.borderWidth = 6
    layer.cornerRadius = 6
    
    let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    leftViewMode = .always
    leftView = spacerView
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

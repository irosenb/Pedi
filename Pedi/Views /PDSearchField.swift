//
//  PDSearchField.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/20/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class PDSearchField: UITextField {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    placeholder = "Where to?"
    attributedPlaceholder = NSAttributedString(string: "Where to?", attributes: [NSAttributedString.Key.foregroundColor: Styles.Colors.purple])
    backgroundColor = Styles.Colors.lightPurple
    
    layer.borderColor = Styles.Colors.purple.cgColor
    layer.borderWidth = 6
    layer.cornerRadius = 6
  }
  
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

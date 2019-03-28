//
//  PDMap.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/21/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
class PDMap: MGLMapView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    styleURL = URL(string: "mapbox://styles/irosenb/cjjyq8qjq801e2rlhdg0i1ceu")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}

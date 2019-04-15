//
//  PDDriver.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/11/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class PDDriver: Mappable {
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    
  }
  
  class func create(firstName: String, lastName: String, password: String, email: String, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
    let params = ["email": email, "password": password, "first_name": firstName, "last_name": lastName ]
    
    Alamofire.request("\(PDServer.baseUrl)/drivers", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
      if let data = response.result.value as? [String: Any] {
        completionHandler(data)
        return
      }
      
      completionHandler(nil)
    }
  }
  
}

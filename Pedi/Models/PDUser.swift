//
//  PDUser.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/8/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class PDUser: Mappable {
  var firstName: String?
  var lastName: String?
  
  required init?(map: Map) {
  }
  
  func mapping(map: Map) {
    firstName <- map["first_name"]
    lastName <- map["last_name"]
  }
  
  class func create(firstName: String, lastName: String, password: String, email: String, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
    let params = ["email": email, "password": password, "first_name": firstName, "last_name": lastName ]
    
    Alamofire.request("https://api.ridepedi.com/users", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
      if let data = response.result.value as? [String: Any] {
        completionHandler(data);
        return;
      }
      
      completionHandler(nil)
    }
  }
}

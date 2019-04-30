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
import MapKit
import SocketIO

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
    
    Alamofire.request("\(PDServer.baseUrl)/users", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
      if let data = response.result.value as? [String: Any] {
        completionHandler(data)
        return
      }
      
      completionHandler(nil)
    }
  }
  
  class func requestRide(start: CLLocation, destination: CLLocation, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
   
//    Alamofire.request("\(PDServer.baseUrl)/rides/request", method: .post, parameters: params, encoding: URLEncoding.default, headers: ["x-session-token": token]).responseJSON { (response) in
//      if let data = response.result.value as? [String: Any] {
//        completionHandler(data)
//        return
//      }
//
//      completionHandler(nil)
//    }
  }
  
  class func checkPrice(eta: Double, distance: Double, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
    guard let token = PDPersonData.authToken() else { return }
    let params = ["eta": eta, "distance": distance]
    
    Alamofire.request("\(PDServer.baseUrl)/rides/price", method: .get, parameters: params, encoding: URLEncoding.default, headers: ["x-session-token": token]).responseJSON { (response) in
      if let data = response.result.value as? [String: Any] {
        completionHandler(data)
        return
      }

      completionHandler(nil)
    }
  }
}

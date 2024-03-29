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
  enum State {
    case requested
    case inactive
    case active
    case enRoute
    case arrived
    case dropOff
  }
  var state: State? 
  
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
  
  class func toggleDriving(isOn: Bool, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
    
    guard let token = PDPersonData.authToken() else { return }
    
    Alamofire.request("\(PDServer.baseUrl)/drivers/toggle", method: .put, parameters: ["is_driving": isOn], encoding: URLEncoding.default, headers: ["x-access-token": token]).responseJSON { (response) in
      if let data = response.result.value as? [String: Any] {
        completionHandler(data)
        return
      }
      
      completionHandler(nil)
    }
  }
  
  class func acceptRide(id: Int, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
    
    
  }
  
  class func setStripe(day: Int, month: Int, year: Int, ssn: String, routing: String, account: String, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
    guard let token = PDPersonData.authToken() else { return }
    guard let driverId = PDPersonData.driverId() else { return }
    let params = [
      "day": day,
      "month": month,
      "year": year,
      "ssn": ssn,
      "driver_id": driverId,
      "routing_number": routing,
      "account_number": account
      ] as [String : Any]
    
    Alamofire.request("\(PDServer.baseUrl)/drivers/stripe", method: .put, parameters: params, encoding: URLEncoding.default, headers: ["x-session-token": token]).responseJSON { (response) in
      if let data = response.result.value as? [String: Any] {
        completionHandler(data)
        return
      }
      
      completionHandler(nil)
    }
  }
  
}

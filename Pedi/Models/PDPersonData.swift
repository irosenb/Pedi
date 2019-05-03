//
//  PDPersonData.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/6/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class PDPersonData: NSObject {
  class func save(object: Any, key: String) {
    let defaults = UserDefaults.standard
    defaults.set(object, forKey: key)
  }
  
  class func saveBool(value: Bool, key: String) {
    let defaults = UserDefaults.standard
    defaults.set(value, forKey: key)
  }
  
  class func getObject(forKey key: String) -> Any? {
    let defaults = UserDefaults.standard
    return defaults.object(forKey: key)
  }
  
  class func getBool(forKey key: String) -> Bool? {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: key)
  }
  
  class func setAuthToken(_ token: String) {
    save(object: token as AnyObject, key: "auth_token")
  }
  
  class func authToken() -> String? {
    guard let token = self.getObject(forKey: "auth_token") as? String else { return nil }
    return token
  }
  
  class func setFirstName(_ firstName: String) {
    save(object: firstName, key: "first_name")
  }
  
  class func firstName() -> String? {
    guard let firstName = self.getObject(forKey: "first_name") as? String else { return nil }
    return firstName
  }
  
  class func setLastName(_ lastName: String) {
    save(object: lastName, key: "last_name")
  }
  
  class func lastName() -> String? {
    guard let lastName = self.getObject(forKey: "last_name") as? String else { return nil }
    return lastName
  }
  
  class func setEmail(_ email: String) {
    save(object: email, key: "email")
  }
  
  class func email() -> String? {
    guard let email = getObject(forKey: "email") as? String else { return nil }
    return email
  }
  
  class func setIsDriver(_ isDriver: Bool) {
    saveBool(value: isDriver, key: "is_driver")
  }
  
  class func isDriver() -> Bool? {
    guard let isDriver = getBool(forKey: "is_driver") else { return nil }
    return isDriver
  }
  
  class func setUserId(_ userId: Int) {
    save(object: userId, key: "user_id")
  }
  
  class func userId() -> Int? {
    guard let userId = getObject(forKey: "user_id") as? Int else { return nil }
    return userId
  }
  
  class func setDriverId(_ userId: Int) {
    save(object: userId, key: "driver_id")
  }
  
  class func driverId() -> Int? {
    guard let driverId = getObject(forKey: "driver_id") as? Int else { return nil }
    return driverId
  }
  
  class func setIsDriving(_ isDriving: Bool) {
    saveBool(value: isDriving, key: "is_driving")
  }
  
  class func isDriving() -> Bool? {
    guard let isDriving = getBool(forKey: "is_driving") else { return nil }
    return isDriving
  }
  
  
}

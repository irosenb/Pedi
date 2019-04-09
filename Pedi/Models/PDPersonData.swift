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
  
  class func getObject(forKey key: String) -> Any? {
    let defaults = UserDefaults.standard
    return defaults.object(forKey: key)
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
}

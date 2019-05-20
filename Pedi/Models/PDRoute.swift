//
//  PDRoute.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/16/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
class PDRoute: NSObject {
  public typealias RouteCompletionHandler = (_ route: Route?, _ error: NSError?) -> Void
  
  class func calculate(start: CLLocation, destination: CLLocation, completionHandler: @escaping RouteCompletionHandler) {
    let waypoints = [
      Waypoint(coordinate: start.coordinate, coordinateAccuracy: -1, name: "start"),
      Waypoint(coordinate: destination.coordinate, coordinateAccuracy: -1, name: "end")
    ]
    
    let options = RouteOptions(waypoints: waypoints, profileIdentifier: .automobile)
    options.includesSteps = true
    options.roadClassesToAvoid = .motorway
    
    let task = Directions.shared.calculate(options) { (waypoints, routes, error) in
      guard error == nil else {
        print("Error calculating directions: \(error!)")
        completionHandler(nil, error)
        return
      }
      
      if let route = routes?.first, let leg = route.legs.first {
        completionHandler(route, nil)
      }
    }
  }
}

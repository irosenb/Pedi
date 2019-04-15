//
//  AcceptRideViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/9/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
import SwiftLocation
import MapboxDirections

class AcceptRideViewController: UIViewController {
  var currentLocation: CLLocation?
  var startPoint: CLLocation?
  var endPoint: CLLocation?
  let accept = UIButton()
  let decline = UIButton()
  let map = PDMap(frame: .zero)
  var time = 4
  let directions = Directions.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addViews()
    addConstraints()
    
    getLocation()
    // Do any additional setup after loading the view.
  }
  
  func addViews() {
    map.translatesAutoresizingMaskIntoConstraints = false
    map.showsUserLocation = true
    view.addSubview(map)

    accept.translatesAutoresizingMaskIntoConstraints = false
    accept.backgroundColor = Styles.Colors.purple
    accept.setTitle("Accept", for: .normal)
    accept.addTarget(self, action: #selector(acceptRide), for: .touchUpInside)
    accept.setTitleColor(.white, for: .normal)
    view.addSubview(accept)
    
    decline.translatesAutoresizingMaskIntoConstraints = false
    decline.addTarget(self, action: #selector(declineRide), for: .touchUpInside)
    decline.setTitle("Decline", for: .normal)
    decline.setTitleColor(.white, for: .normal)
    view.addSubview(decline)
    
  }
  
  func addConstraints() {
    accept.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
    accept.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
    accept.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    decline.topAnchor.constraint(equalTo: view.topAnchor, constant: -30).isActive = true
    decline.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
    decline.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    map.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
    map.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0).isActive = true
  }
  
  func getLocation() {
    if Locator.authorizationStatus == .denied {
      return
    }
    
    Locator.currentPosition(accuracy: .block, onSuccess: { (location) -> (Void) in
      self.currentLocation = location
      self.map.setCenter(location.coordinate, zoomLevel: 14, animated: true)
      
      self.calculateDirections()
      
    }) { (error, location) -> (Void) in
//      self.showError(error: error)
      print("failed: \(error)")
    }
  }
  
  func calculateDirections() {
    guard let beginningPoint = currentLocation else { return }
    guard let end = endPoint else { return }
    let waypoints = [
      Waypoint(coordinate: beginningPoint.coordinate, coordinateAccuracy: -1, name: "start"),
      Waypoint(coordinate: end.coordinate, coordinateAccuracy: -1, name: "end")
    ]
    
    let options = RouteOptions(waypoints: waypoints, profileIdentifier: .cycling)
    options.includesSteps = true
    
    let task = directions.calculate(options) { (waypoints, routes, error) in
      guard error == nil else {
        print("Error calculating directions: \(error!)")
        return
      }
      
      if let route = routes?.first, let leg = route.legs.first {
        print("Route via \(leg):")
        
        let distanceFormatter = LengthFormatter()
        let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
        
        let travelTimeFormatter = DateComponentsFormatter()
        travelTimeFormatter.unitsStyle = .short
        let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
        
        print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
        
        var routeCoordinates = route.coordinates!
        let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        // Add the polyline to the map and fit the viewport to the polyline.
        let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
        
        self.map.addAnnotation(routeLine)
        self.map.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: edge, animated: true)
        
      }
    }
  }
  
  @objc func acceptRide() {
    
  }
  
  @objc func declineRide() {
    
  }
}

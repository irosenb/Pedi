//
//  PreviewViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/29/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder
import MapboxDirections

class PreviewViewController: UIViewController {
  var destination: Placemark?
  var currentLocation: CLLocation?
  var start: Placemark?
  var price: Double = 30
  let destinationBar = DestinationBar()
  let requestRide = UIButton()
  let priceLabel = UILabel()
  let map = PDMap(frame: .zero)
  let directions = Directions.shared
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = true

    view.backgroundColor = .white
    
    setStartText()
    
    addViews()
    addConstraints()
    
    calculateDirections()
  }
  
  func addViews() {
    map.translatesAutoresizingMaskIntoConstraints = false
    map.showsUserLocation = true
    view.addSubview(map)

    destinationBar.translatesAutoresizingMaskIntoConstraints = false
    destinationBar.destination.text = destination?.name
    view.addSubview(destinationBar)
    
    requestRide.translatesAutoresizingMaskIntoConstraints = false
    requestRide.setTitle("Request ride", for: .normal)
    requestRide.backgroundColor = Styles.Colors.purple
    requestRide.setTitleColor(.white, for: .normal)
    view.addSubview(requestRide)
    
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    priceLabel.font = UIFont.systemFont(ofSize: 30)
    priceLabel.textColor = Styles.Colors.purple
    priceLabel.text = "$\(price)"
    priceLabel.sizeToFit()
    view.addSubview(priceLabel)
  }
  
  
  func addConstraints() {
    destinationBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -40).isActive = true
    destinationBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
    destinationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    destinationBar.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    
    requestRide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    requestRide.heightAnchor.constraint(equalToConstant: 60).isActive = true
    requestRide.bottomAnchor.constraint(equalTo: view.bottomAnchor
      , constant: 0).isActive = true
    
    priceLabel.bottomAnchor.constraint(equalTo: requestRide.topAnchor, constant: -30).isActive = true
    priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    
    map.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    map.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
  }
  
  func calculateDirections() {
    guard let startPoint = currentLocation else { return }
    guard let endPoint = destination?.location else { return }
    let waypoints = [
      Waypoint(coordinate: startPoint.coordinate, coordinateAccuracy: -1, name: "start"),
      Waypoint(coordinate: endPoint.coordinate, coordinateAccuracy: -1, name: "end")
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
  
  func setStartText() {
    if ((start?.location) == nil) {
      destinationBar.start.text = "Current location"
    } else {
      destinationBar.start.text = start?.name
    }
  }
}

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
import SocketIO

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
  let activityIndicator = UIActivityIndicatorView()
  let manager = SocketManager(socketURL: URL(string: PDServer.baseUrl)!)
  var socket: SocketIOClient!
  var rideId: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let authToken = PDPersonData.authToken() else { return }
    manager.config = [.extraHeaders(["x-access-token": authToken])]
    
    socket = manager.defaultSocket
    socket.connect()
    
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
    requestRide.addTarget(self, action: #selector(getRide), for: .touchUpInside)
    view.addSubview(requestRide)
    
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    priceLabel.font = UIFont.systemFont(ofSize: 30)
    priceLabel.textColor = Styles.Colors.purple
    priceLabel.text = "$\(price)"
    priceLabel.sizeToFit()
    view.addSubview(priceLabel)
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
  }
  
  
  func addConstraints() {
    destinationBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -40).isActive = true
    destinationBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
    destinationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    destinationBar.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    
    requestRide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    requestRide.heightAnchor.constraint(equalToConstant: 60).isActive = true
    requestRide.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor
      , constant: 0).isActive = true
    
    priceLabel.bottomAnchor.constraint(equalTo: requestRide.topAnchor, constant: -30).isActive = true
    priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    
    activityIndicator.centerXAnchor.constraint(equalTo: requestRide.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: requestRide.centerYAnchor).isActive = true
    
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
  
  @objc func getRide() {
    guard let startPoint = currentLocation else { return }
    guard let endPoint = destination?.location else { return }
    
    requestRide.setTitle("", for: .normal)
    activityIndicator.startAnimating()
    
    guard let userId = PDPersonData.userId() else { return }
    
    let params: [String: Any] = ["start_latitude": startPoint.coordinate.latitude, "start_longitude": startPoint.coordinate.longitude, "destination_latitude": endPoint.coordinate.latitude, "destination_longitude": endPoint.coordinate.longitude, "user_id": userId]
    self.socket.emit("rideRequest", params)
    self.monitorAcceptedRide()
  }
  
  func monitorAcceptedRide() {
    self.socket.on("rideRequest") { (data, ack) in
      guard let params = data as? [[String: Any]] else { return }
      guard let rideId = params[0]["ride_id"] as? Int else { return }
      
      guard self.rideId == nil else {
        return
      }
      
      self.rideId = rideId
    }
    
    self.socket.on("rideLocation") { (data, ack) in
      self.requestRide.isHidden = true
      self.activityIndicator.stopAnimating()

      guard let annotations = self.map.annotations else { return }
      self.map.removeAnnotations(annotations)
      
      guard let loc = data as? [[String: Any]] else { return }
      guard let latitude = loc[0]["latitude"] as? CLLocationDegrees else { return }
      guard let longitude = loc[0]["longitude"] as? CLLocationDegrees else { return }
      guard let acceptedRide = loc[0]["ride_id"] as? Int else { return }
      
      if acceptedRide == self.rideId {
        let startPoint = CLLocation(latitude: latitude, longitude: longitude)
        guard let destination = self.currentLocation else { return }
        
        PDRoute.calculate(start: startPoint, destination: destination, completionHandler: { (route, error) in
          guard let rte = route else {
            // There is an error
            return
          }
          let distanceFormatter = LengthFormatter()
          let formattedDistance = distanceFormatter.string(fromMeters: rte.distance)
          
          let travelTimeFormatter = DateComponentsFormatter()
          travelTimeFormatter.unitsStyle = .short
          let formattedTravelTime = travelTimeFormatter.string(from: rte.expectedTravelTime)
          
          var routeCoordinates = rte.coordinates!
          let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: rte.coordinateCount)
          
          // Add the polyline to the map and fit the viewport to the polyline.
          let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
          
          self.map.addAnnotation(routeLine)
          self.map.setVisibleCoordinates(&routeCoordinates, count: rte.coordinateCount, edgePadding: edge, animated: true)
        })
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

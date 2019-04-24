//
//  DriverViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 4/11/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import SocketIO
import Mapbox
import MapboxDirections
import SwiftLocation

class DriverViewController: UIViewController {
  let dashboard = DriverDashboard()
  let manager = SocketManager(socketURL: URL(string: PDServer.baseUrl)!)
  var socket: SocketIOClient!
  let map = PDMap(frame: .zero)
  let directions = Directions.shared
  var currentLocation: CLLocation?
  let acceptButton = UIButton()
  var rideId: Int?
  var destination: CLLocation?
  var declinedRides: [Int] = []
  let declineButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let authToken = PDPersonData.authToken() else { return }
    manager.config = [.extraHeaders(["x-access-token": authToken])]
    
    socket = manager.defaultSocket
    socket.connect()
    
    navigationController?.navigationBar.isHidden = true
    
    addViews()
    addConstraints()
    
    getLocation()
  }
  
  func addViews() {
    map.translatesAutoresizingMaskIntoConstraints = false
    map.showsUserLocation = true
    view.addSubview(map)

    dashboard.translatesAutoresizingMaskIntoConstraints = false
    dashboard.toggle.addTarget(self, action: #selector(toggleDriving), for: .valueChanged)
    view.addSubview(dashboard)
    
    acceptButton.translatesAutoresizingMaskIntoConstraints = false
    acceptButton.addTarget(self, action: #selector(acceptRide), for: .touchUpInside)
    acceptButton.backgroundColor = Styles.Colors.purple
    acceptButton.setTitle("Accept Ride", for: .normal)
    acceptButton.isHidden = true
    view.addSubview(acceptButton)
    
    declineButton.translatesAutoresizingMaskIntoConstraints = false
    declineButton.addTarget(self, action: #selector(declineRide), for: .touchUpInside)
    declineButton.setTitle("X", for: .normal)
    declineButton.backgroundColor = Styles.Colors.darkPurple
    declineButton.isHidden = true
    view.addSubview(declineButton)
  }
  
  func addConstraints() {
    dashboard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: 0).isActive = true
    dashboard.heightAnchor.constraint(equalToConstant: 60).isActive = true
    dashboard.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
    
    map.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
    map.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    
    acceptButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    acceptButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    acceptButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
    declineButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 70).isActive = true
    declineButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    declineButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    declineButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    
  }
  
  @objc func toggleDriving() {
    var isDriving = dashboard.toggle.isOn
    
    PDDriver.toggleDriving(isOn: isDriving) { (data) in
      if (isDriving) {
       self.monitorRideRequest()
      }
    }
  }
  
  @objc func declineRide() {
    acceptButton.isHidden = true
    declineButton.isHidden = true
    
    guard let ride = rideId else { return }
    declinedRides.append(ride)
    
    guard let annotations = map.annotations else { return }
    map.removeAnnotations(annotations)
  }
  
  func monitorRideRequest() {
    self.socket.on("rideRequest", callback: { (data, ack) in
      print(data);
      guard let params = data as? [[String: Any]] else { return }
      guard let latitude = params[0]["start_latitude"] as? Double else { return }
      guard let longitude = params[0]["start_longitude"] as? Double else { return }
      
      guard let rideId = params[0]["ride_id"] as? Int else { return }
      guard self.rideId == nil else { return }
      guard !self.declinedRides.contains(rideId) else { return }
      
      self.rideId = rideId
      
      let location = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
      
      self.destination = location
      self.calculateDirections(destination: location)
      
      self.acceptButton.isHidden = false
      self.declineButton.isHidden = false
      
    })
  }
  
  @objc func acceptRide() {
    guard let ride = rideId else { return }
    guard let driverId = PDPersonData.driverId() else { return }
    self.socket.emit("acceptRide", with: [["ride_id": ride, "driver_id": driverId]])
    
    self.acceptButton.setTitle("Tap to arrive", for: .normal)
    self.acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
    self.acceptButton.addTarget(self, action: #selector(arrive), for: .touchUpInside)
    
    self.declineButton.isHidden = true
    
    Locator.subscribePosition(accuracy: .room, onUpdate: { (location) -> (Void) in
      self.currentLocation = location
      self.socket.emit("rideLocation", with: [["ride_id": ride, "latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]])
      
      PDRoute.calculate(start: location, destination: self.destination!, completionHandler: { (rte, err) in
        if err != nil {
          return
        }
        
        guard let route = rte else { return }
        let routeLine = MGLPolyline(coordinates: route.coordinates!, count: route.coordinateCount)
        
        let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
        
        self.map.removeAnnotations(self.map.annotations!)
        self.map.addAnnotation(routeLine)
        
        self.map.setVisibleCoordinates(route.coordinates!, count: route.coordinateCount, edgePadding: edge, animated: true)
      })
    }) { (error, location) -> (Void) in
    }
    
  }
  
  func getLocation() {
    if Locator.authorizationStatus == .denied {
      return
    }
    
    Locator.currentPosition(accuracy: .block, onSuccess: { (location) -> (Void) in
      self.currentLocation = location
      self.map.setCenter(location.coordinate, zoomLevel: 14, animated: true)
    }) { (error, location) -> (Void) in
      //      self.showError(error: error)
      print("failed: \(error.localizedDescription)")
    }
  }
  
  @objc func arrive() {
    guard let ride = rideId else { return }
    socket.emit("arrived", ["ride_id": ride])
    
    acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
    acceptButton.addTarget(self, action: #selector(pickUp), for: .touchUpInside)
    acceptButton.setTitle("Pick up", for: .normal)
    
    
  }
  
  @objc func pickUp() {
    guard let ride = rideId else { return }
    socket.emit("pickUp", ["ride_id": ride])
    
    acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
    acceptButton.addTarget(self, action: #selector(dropOff), for: .touchUpInside)
    acceptButton.setTitle("Drop off", for: .normal)
  }
  
  @objc func dropOff() {
    acceptButton.isHidden = true
    
  }
  
  func calculateDirections(destination: CLLocation) {
    guard let startPoint = map.userLocation?.location else { return }
    let waypoints = [
      Waypoint(coordinate: startPoint.coordinate, coordinateAccuracy: -1, name: "start"),
      Waypoint(coordinate: destination.coordinate, coordinateAccuracy: -1, name: "end")
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
        print("getting directions")
        self.map.addAnnotation(routeLine)
        self.map.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: edge, animated: true)
        
      }
    }
  }
}

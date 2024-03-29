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
import MapboxNavigation

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
  var pickup: CLLocation?
  var declinedRides: [Int] = []
  let declineButton = UIButton()
  var pickedUp = false
  var droppedOff = false
  var locationSubscription: LocationRequest?
  var subscription: LocationRequest?
  var pickup_address: String?
  var destination_address: String?
  let destinationView = UILabel()
  let locationManager = CLLocationManager()
  
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
    dashboard.cancel.addTarget(self, action: #selector(declineRide), for: .touchUpInside)
    view.addSubview(dashboard)
    
    acceptButton.translatesAutoresizingMaskIntoConstraints = false
    acceptButton.addTarget(self, action: #selector(acceptRide), for: .touchUpInside)
    acceptButton.backgroundColor = Styles.Colors.purple
    acceptButton.setTitle("Accept Ride", for: .normal)
    acceptButton.isHidden = true
    view.addSubview(acceptButton)
    
    destinationView.font = UIFont.boldSystemFont(ofSize: 20)
    destinationView.textColor = Styles.Colors.purple
    destinationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(destinationView)
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
    
//    declineButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 70).isActive = true
//    declineButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//    declineButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
//    declineButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
//
    destinationView.topAnchor.constraint(equalTo: dashboard.bottomAnchor, constant: 20).isActive = true
    destinationView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
    destinationView.heightAnchor.constraint(equalToConstant: 140).isActive = true
    
  }
  
  @objc func toggleDriving() {
    var isDriving = dashboard.toggle.isOn
    
    PDDriver.toggleDriving(isOn: isDriving) { (data) in
      if (isDriving) {
        self.monitorRideRequest()
        self.monitorAcceptedRide()
      }
    }
  }
  
  @objc func declineRide() {
    acceptButton.isHidden = true
    dashboard.cancel.isHidden = true
    
    guard let ride = rideId else { return }
    declinedRides.append(ride)
    
    guard let annotations = map.annotations else { return }
    map.removeAnnotations(annotations)
    
    destinationView.isHidden = true
    
    self.rideId = nil
  }
  
  func monitorAcceptedRide() {
    self.socket.on("acceptRide") { (data, ack) in
      guard let params = data as? [[String: Any]] else { return }
      guard let rideId = params[0]["id"] as? Int else { return }
      guard let driverId = params[0]["driver_id"] as? String else { return }
      guard let currentDriver = PDPersonData.driverId() else { return }
      
      if rideId == self.rideId && Int(driverId) != currentDriver {
        self.destinationView.isHidden = true
        
        self.dashboard.cancel.isHidden = true
        self.acceptButton.isHidden = true
        
        guard let annotations = self.map.annotations else { return }
        self.map.removeAnnotations(annotations)
      }
    }
  }
  
  func monitorRideRequest() {
    self.socket.on("rideRequest", callback: { (data, ack) in
      print(data);
      guard let params = data as? [[String: Any]] else { return }
      guard let latitude = params[0]["start_latitude"] as? Double else { return }
      guard let longitude = params[0]["start_longitude"] as? Double else { return }
      
      guard let destinationLatitude = params[0]["destination_latitude"] as? Double else { return }
      guard let destinationLongitude = params[0]["destination_longitude"] as? Double else { return }
      
      guard let pickup_addr = params[0]["pickup_address"] as? String else { return }
      guard let destination_addr = params[0]["destination_address"] as? String else { return }
      
      self.pickup_address = pickup_addr
      self.destination_address = destination_addr
      
      self.destinationView.isHidden = false
      self.destinationView.text = pickup_addr
      
      guard let rideId = params[0]["ride_id"] as? Int else { return }
      guard self.rideId == nil else { return }
      guard !self.declinedRides.contains(rideId) else { return }
      
      self.rideId = rideId
      
      self.destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
      self.pickup = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
      
      self.calculateDirections(destination: self.pickup!)
      
      self.acceptButton.isHidden = false
      self.dashboard.cancel.isHidden = false
      
    })
  }
  
  @objc func acceptRide() {
    guard let ride = rideId else { return }
    guard let driverId = PDPersonData.driverId() else { return }
    self.socket.emit("acceptRide", with: [["ride_id": ride, "driver_id": driverId]])
    
    self.acceptButton.setTitle("Tap to arrive", for: .normal)
    self.acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
    self.acceptButton.addTarget(self, action: #selector(arrive), for: .touchUpInside)
    
    self.dashboard.cancel.isHidden = true
    
    let controller = DirectionsViewController()
    
    controller.origin = currentLocation
    controller.pickup = pickup
    controller.destination = destination
    controller.rideId = rideId
    
    navigationController?.pushViewController(controller, animated: false)

    self.rideId = nil
    self.map.removeAnnotations(map.annotations!)
    
    destinationView.isHidden = true
    
    acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
    acceptButton.addTarget(self, action: #selector(acceptRide), for: .touchUpInside)
    acceptButton.setTitle("Accept Ride", for: .normal)
    
    acceptButton.isHidden = true
  }
  
  func getLocation() {
    self.locationManager.delegate = self
    self.locationManager.requestLocation()
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
    self.pickedUp = true
    socket.emit("pickUp", ["ride_id": ride])
    
    acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
    acceptButton.addTarget(self, action: #selector(dropOff), for: .touchUpInside)
    acceptButton.setTitle("Drop off", for: .normal)
    
    self.subscription = Locator.subscribePosition(accuracy: .room, onUpdate: { (location) -> (Void) in
      PDRoute.calculate(start: location, destination: self.destination!) { (rte, error) in
        guard let route = rte else { return }
        
        if let annotations = self.map.annotations {
          self.map.removeAnnotations(annotations)
        }
        
        self.map.addRoute(route)
      }
    }) { (error, location) -> (Void) in
      
    }
    
  }
  
  @objc func dropOff() {
    guard let ride = rideId else { return }
    acceptButton.isHidden = true
    
    self.socket.emit("dropOff", ["ride_id": ride])
    
    Locator.stopRequest(subscription!)
    Locator.stopRequest(locationSubscription!)
    
    self.rideId = nil
    self.map.removeAnnotations(map.annotations!)
    
    destinationView.isHidden = true
    
    acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
    acceptButton.addTarget(self, action: #selector(acceptRide), for: .touchUpInside)
    acceptButton.setTitle("Accept Ride", for: .normal)
    
    self.getLocation()
  }
  
  func calculateDirections(destination: CLLocation) {
    guard let startPoint = map.userLocation?.location else { return }
    let waypoints = [
      Waypoint(coordinate: startPoint.coordinate, coordinateAccuracy: -1, name: "start"),
      Waypoint(coordinate: destination.coordinate, coordinateAccuracy: -1, name: "end")
    ]
    
    let options = RouteOptions(waypoints: waypoints, profileIdentifier: .automobile)
    options.includesSteps = true
    options.roadClassesToAvoid = .motorway
    
    let task = directions.calculate(options) { (waypoints, routes, error) in
      guard error == nil else {
        print("Error calculating directions: \(error!)")
        return
      }
      
      if let route = routes?.first, let leg = route.legs.first {
        self.map.addRoute(route)
        
        let destinationAnnotation = MGLPointAnnotation()
        destinationAnnotation.coordinate = destination.coordinate
        
        let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
        
        var routeCoordinates = route.coordinates!
        self.map.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: edge, animated: true)

        self.map.addAnnotation(destinationAnnotation)
      }
    }
  }
}

extension DriverViewController: NavigationViewControllerDelegate {
}

extension DriverViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    self.currentLocation = location
    self.map.setCenter(location.coordinate, zoomLevel: 14, animated: true)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error: \(error)")
  }
}

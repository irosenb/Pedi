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
import SwiftLocation

class PreviewViewController: UIViewController {
  var destination: Placemark?
  var currentLocation: CLLocation?
  var start: Placemark?
  var price: Double?
  let destinationBar = DestinationBar()
  let requestRide = UIButton()
  let priceLabel = UILabel()
  let map = PDMap(frame: .zero)
  let directions = Directions.shared
  let activityIndicator = UIActivityIndicatorView()
  let manager = SocketManager(socketURL: URL(string: PDServer.baseUrl)!)
  var socket: SocketIOClient!
  var rideId: Int?
  var estimatedTime: TimeInterval?
  var distance: CLLocationDistance?
  var subscription: LocationRequest?
  
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
    requestRide.setTitle("", for: .normal)
    requestRide.backgroundColor = Styles.Colors.purple
    requestRide.setTitleColor(.white, for: .normal)
    requestRide.addTarget(self, action: #selector(getRide), for: .touchUpInside)
    view.addSubview(requestRide)
    
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    priceLabel.font = UIFont.systemFont(ofSize: 30)
    priceLabel.textColor = Styles.Colors.purple
    priceLabel.sizeToFit()
    priceLabel.isHidden = true
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
  
  func getPrice(eta: Double, distance: Double) {
    activityIndicator.startAnimating()
    
    requestRide.setTitle("", for: .normal)
    requestRide.isEnabled = false
    
    self.estimatedTime = eta
    self.distance = distance
    
    PDUser.checkPrice(eta: eta, distance: distance) { (data) in
      guard let result = data else { return }
      guard let price = result["price"] as? Double else { return }
      
      self.price = price
      
      self.requestRide.isEnabled = true
      self.activityIndicator.stopAnimating()
      self.requestRide.setTitle("$\(price) • Request ride", for: .normal)
    }
  }
  
  func calculateDirections() {
    guard let startPoint = currentLocation else { return }
    guard let endPoint = destination?.location else { return }
    let waypoints = [
      Waypoint(coordinate: startPoint.coordinate, coordinateAccuracy: -1, name: "start"),
      Waypoint(coordinate: endPoint.coordinate, coordinateAccuracy: -1, name: "end")
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
        print("Route via \(leg):")
        self.getPrice(eta: route.expectedTravelTime, distance: route.distance)
        
        var routeCoordinates = route.coordinates!
        let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
        self.map.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: edge, animated: true)
        self.map.addRoute(route)
      }
    }
  }
  
  @objc func getRide() {
    guard let startPoint = currentLocation else { return }
    guard let endPoint = destination?.location else { return }
    
    requestRide.setTitle("", for: .normal)
    activityIndicator.startAnimating()
    
    guard let userId = PDPersonData.userId() else { return }
    guard let eta = estimatedTime else { return }
    guard let dist = distance else { return }
    
    let options = ReverseGeocodeOptions(coordinate: startPoint.coordinate)
    
    let task = Geocoder.shared.geocode(options) { (places, attribution, error) in
      guard let placemark = places?.first else {
        return
      }

      let params: [String: Any] = [
        "start_latitude": startPoint.coordinate.latitude,
        "start_longitude": startPoint.coordinate.longitude,
        "destination_latitude": endPoint.coordinate.latitude,
        "destination_longitude": endPoint.coordinate.longitude,
        "user_id": userId,
        "estimated_time": eta,
        "distance": dist,
        "price": self.price,
        "destination_address": self.destination?.qualifiedName,
        "pickup_address": placemark.qualifiedName
      ]
      
      self.socket.emit("rideRequest", params)
      
      self.monitorAcceptedRide()
      self.monitorPickUp()
      self.monitorDropOff()
    }
    
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
        let destination = CLLocation(latitude: latitude, longitude: longitude)
        guard let startPoint = self.currentLocation else { return }
        
        PDRoute.calculate(start: startPoint, destination: destination, completionHandler: { (route, error) in
          guard let rte = route else {
            // There is an error
            return
          }
          let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
          
          var routeCoordinates = rte.coordinates!
          self.map.setVisibleCoordinates(&routeCoordinates, count: rte.coordinateCount, edgePadding: edge, animated: true)
          self.map.addRoute(rte)
        })
      }
    }
  }
  
  func monitorPickUp() {
    self.socket.on("pickUp") { (data, ack) in
      guard let result = data as? [[String: Any]] else { return }
      guard let coordinates = result[0]["destination"] as? [Double] else { return }
      
      // Make sure it's the same ride
      guard let pickupRide = result[0]["id"] as? Int else { return }
      guard let ride = self.rideId else { return }
      guard pickupRide == ride else { return }
      
      let destination = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
      
      Locator.subscribePosition(accuracy: .room, onUpdate: { (location) -> (Void) in
        self.currentLocation = location
        PDRoute.calculate(start: location, destination: destination, completionHandler: { (route, err) in
          guard let rte = route else { return }
          guard let annotations = self.map.annotations else { return }
          
          let destinationAnnotation = MGLPointAnnotation()
          destinationAnnotation.coordinate = destination.coordinate
          
          self.map.addAnnotation(destinationAnnotation)
          
          self.map.removeAnnotations(annotations)
          self.map.addRoute(rte)
        })
      }, onFail: { (err, location) -> (Void) in
        
      })
      
    }
  }
  
  func monitorDropOff() {
    self.socket.on("dropOff") { (data, ack) in
      guard let result = data as? [[String: Any]] else { return }
      
      // Make sure it's the same ride
      guard let pickupRide = result[0]["ride_id"] as? Int else { return }
      guard let ride = self.rideId else { return }
      guard pickupRide == ride else { return }
      
      self.map.removeAnnotations(self.map.annotations!)
      
      self.rideId = nil
      
      self.dismiss(animated: true, completion: nil)
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

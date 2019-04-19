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
  
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let authToken = PDPersonData.authToken() else { return }
    manager.config = [.extraHeaders(["x-access-token": authToken])]
    
    socket = manager.defaultSocket
    
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
    
  }
  
  @objc func toggleDriving() {
    var isDriving = dashboard.toggle.isOn
    
    PDDriver.toggleDriving(isOn: isDriving) { (data) in
      if (isDriving) {
        self.socket.connect()
        self.socket.on(clientEvent: .connect, callback: { (data, ack) in
          print("Socket connected")
  
          self.monitorRideRequest()
        })
        
      }
    }
  }
  
  func monitorRideRequest() {
    self.socket.on("rideRequest", callback: { (data, ack) in
      print(data);
      guard let params = data as? [[String: Any]] else { return }
      guard let latitude = params[0]["start_latitude"] as? Double else { return }
      guard let longitude = params[0]["start_longitude"] as? Double else { return }
      
      let location = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
      
      self.calculateDirections(destination: location)
      
      self.acceptButton.isHidden = false
    })
  }
  
  @objc func acceptRide() {
    self.socket.emit("acceptRide", with: [])
    
    self.acceptButton.setTitle("Tap to arrive", for: .normal)
    self.acceptButton.removeTarget(self, action: nil, for: .touchUpInside)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

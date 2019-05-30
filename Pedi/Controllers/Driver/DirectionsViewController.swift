//
//  DirectionsViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 5/21/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections
import SocketIO

class DirectionsViewController: UIViewController {
  let acceptButton = UIButton()
  let directions = Directions.shared
  var origin: CLLocation?
  var pickup: CLLocation?
  var destination: CLLocation?
  var rideId: Int?
  var route: Route?
  let manager = SocketManager(socketURL: URL(string: PDServer.baseUrl)!)
  var socket: SocketIOClient!
  var pickedUp = false
  let locationManager = CLLocationManager()
  var currentLocation: CLLocation?
  var navigationViewController: NavigationViewController!
  
  lazy var options: NavigationRouteOptions = {
    let origin = self.origin?.coordinate
    let destination = self.pickup?.coordinate
    let options = NavigationRouteOptions(coordinates: [origin!, destination!])
    options.roadClassesToAvoid = .motorway
    return options
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let authToken = PDPersonData.authToken() else { return }
    manager.config = [.extraHeaders(["x-access-token": authToken])]
    
    socket = manager.defaultSocket
    socket.connect()
    
    view.backgroundColor = .white
    
    addViews()
    addConstraints()
    
    self.socket.once(clientEvent: .connect) { (data, ack) in
      self.locationManager.delegate = self
      self.locationManager.startUpdatingLocation()
    }
    
  }
  
  func addViews() {
    acceptButton.translatesAutoresizingMaskIntoConstraints = false
    acceptButton.addTarget(self, action: #selector(arrive), for: .touchUpInside)
    acceptButton.backgroundColor = Styles.Colors.purple
    acceptButton.setTitle("Tap to Arrive", for: .normal)
    view.addSubview(acceptButton)
    
    directions.calculate(options) { (waypoints, routes, error) in
      guard let route = routes?.first, error == nil else {
        print(error!.localizedDescription)
        return
      }
      self.route = route
  
      let navigationService = MapboxNavigationService(route: route, simulating: .onPoorGPS)
      let navigationOptions = NavigationOptions(navigationService: navigationService)
      self.navigationViewController = NavigationViewController(for: route, options: navigationOptions)
      self.navigationViewController.delegate = self
      self.navigationViewController.showsReportFeedback = false
      
      self.addChild(self.navigationViewController)
      self.view.addSubview(self.navigationViewController.view)
      self.navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        self.navigationViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
        self.navigationViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        self.navigationViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
        self.navigationViewController.view.bottomAnchor.constraint(equalTo: self.acceptButton.topAnchor, constant: 0)
        ])
      
    }
    
  }

  func addConstraints() {
    acceptButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    acceptButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    acceptButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
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
    
    options = NavigationRouteOptions(locations: [currentLocation!, destination!])
    options.roadClassesToAvoid = .motorway
    directions.calculate(options) { (waypoints, routes, error) in
      guard let route = routes?.first, error == nil else {
        print(error!.localizedDescription)
        return
      }
      self.route = route
      self.navigationViewController.route = route
    }
  }
  
  @objc func dropOff() {
    guard let ride = rideId else { return }
    acceptButton.isHidden = true
    
    self.socket.emit("dropOff", ["ride_id": ride])
    
    self.rideId = nil
    
    self.navigationController?.popViewController(animated: false)
    
  }

}

extension DirectionsViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    self.currentLocation = location
    guard let ride = rideId else { return }
    
    if !pickedUp {
      self.socket.emit("rideLocation", with: [["ride_id": ride, "latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]])
    }
    
  }
}

extension DirectionsViewController: NavigationViewControllerDelegate {
  
}

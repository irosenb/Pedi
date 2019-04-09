//
//  ViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/20/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import SwiftLocation
import MapKit

class RequestRideViewController: UIViewController {
  let searchField = PDTextField()
  var searchBottom: NSLayoutConstraint?
  let map = PDMap(frame: .zero)
  var location: CLLocation?
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    navigationController?.navigationBar.isHidden = true
    
    map.showsUserLocation = true
    
    addViews()
    addConstraints()
    
    searchField.addTarget(self, action: #selector(selectDestination), for: .editingDidBegin)
    
    NotificationCenter.default.addObserver(self, selector: #selector(RequestRideViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

    
    getLocation()
  }
  
  func addViews() {
    map.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(map)

    searchField.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(searchField)
    
  }
  
  func addConstraints() {
    searchBottom = NSLayoutConstraint(item: searchField, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -32)
    let searchWidth = NSLayoutConstraint(item: searchField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
    let searchHeight = NSLayoutConstraint(item: searchField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
    let searchCenterX = NSLayoutConstraint(item: searchField, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    view.addConstraints([searchBottom!, searchWidth, searchHeight, searchCenterX])
    
    map.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
    map.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
  }

  @objc func selectDestination() {
    searchField.endEditing(true)
    
    let destinationController = DestinationViewController()
    destinationController.currentLocation = self.location
    
    let nav = UINavigationController(rootViewController: destinationController)
    
    present(nav, animated: true, completion: nil)
  }
  
  func getLocation() {
    if Locator.authorizationStatus == .denied {
      return
    }
    
    Locator.currentPosition(accuracy: .block, onSuccess: { (location) -> (Void) in
      self.location = location
      self.map.setCenter(location.coordinate, zoomLevel: 14, animated: true)
    }) { (error, location) -> (Void) in
      self.showError(error: error)
      print("failed: \(error)")
    }
  }
  
  @objc func keyboardWillShow(notification: Notification) {
    let frame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    searchBottom?.constant = -frame.height - 10
    view.setNeedsLayout()
  }
  
  func showError(error: Error) {
    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}


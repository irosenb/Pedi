//
//  PDMap.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/21/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections

class PDMap: MGLMapView, MGLMapViewDelegate {
  override init(frame: CGRect) {
    super.init(frame: frame)
    styleURL = URL(string: "mapbox://styles/irosenb/cjjyq8qjq801e2rlhdg0i1ceu")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addRoute(_ route: Route) {
    let distanceFormatter = LengthFormatter()
    let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
    
    let travelTimeFormatter = DateComponentsFormatter()
    travelTimeFormatter.unitsStyle = .short
    let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
    
    var routeCoordinates = route.coordinates!
    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
    
    // Add the polyline to the map and fit the viewport to the polyline.
    let edge = UIEdgeInsets(top: 60, left: 10, bottom: 60, right: 10)
    
    addAnnotation(routeLine)
    
  }
  
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
      // This example is only concerned with point annotations.
      guard annotation is MGLPointAnnotation else {
        return nil
      }
      
      // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
      let reuseIdentifier = "\(annotation.coordinate.longitude)"
      
      // For better performance, always try to reuse existing annotations.
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
      
      // If there’s no reusable annotation view available, initialize a new one.
      if annotationView == nil {
        annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
        annotationView!.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        // Set the annotation view’s background color to a value determined by its longitude.
        annotationView!.backgroundColor = Styles.Colors.darkPurple
      }
      
      return annotationView
  }
}

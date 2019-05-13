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
    self.delegate = self
    self.tintColor = Styles.Colors.purple
    styleURL = URL(string: "mapbox://styles/irosenb/cjvfkixynn7ot1frvg37pfflr")
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
  
  func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
    // Set the alpha for all shape annotations to 1 (full opacity)
    return 1
  }
  
  func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
    // Set the line width for polyline annotations
    return 5.0
  }
  
  func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    // Give our polyline a unique color by checking for its `title` property
    return Styles.Colors.darkPurple
  }
}

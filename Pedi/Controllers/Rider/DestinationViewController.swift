//
//  DestinationViewController.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/29/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder

class DestinationViewController: UIViewController, UITextFieldDelegate {
  let startTextField = PDTextField()
  let destinationTextField = PDTextField()
  let tableView = UITableView()

  let geocoder = Geocoder.shared
  var searchResults: [Placemark] = []
  var currentLocation: CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addViews()
    addConstraints()
    
    view.backgroundColor = .white
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DestinationViewController.dismissVC))
    
    tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultTableViewCell")
      // Do any additional setup after loading the view.
  }
  
  func addViews() {
    startTextField.translatesAutoresizingMaskIntoConstraints = false
    startTextField.placeholder = "Current Location"
    view.addSubview(startTextField)
    
    destinationTextField.translatesAutoresizingMaskIntoConstraints = false
    destinationTextField.becomeFirstResponder()
    destinationTextField.delegate = self
    view.addSubview(destinationTextField)
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)
  }
  
  func addConstraints() {
    let startTop = NSLayoutConstraint(item: startTextField, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 67)
    let searchWidth = NSLayoutConstraint(item: startTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
    let searchHeight = NSLayoutConstraint(item: startTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
    let searchCenterX = NSLayoutConstraint(item: startTextField, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    view.addConstraints([startTop, searchWidth, searchHeight, searchCenterX])
    
    let destinationTop = NSLayoutConstraint(item: destinationTextField, attribute: .top, relatedBy: .equal, toItem: startTextField, attribute: .bottom, multiplier: 1, constant: -5)
    let destinationWidth = NSLayoutConstraint(item: destinationTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
    let destinationHeight = NSLayoutConstraint(item: destinationTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
    let destinationCenterX = NSLayoutConstraint(item: destinationTextField, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    view.addConstraints([destinationTop, destinationHeight, destinationWidth, destinationCenterX])
    
    let tableViewTop = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: destinationTextField, attribute: .bottom, multiplier: 1, constant: 0)
    let tableViewBottom = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
    let tableViewWidth = NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
    view.addConstraints([tableViewTop, tableViewWidth, tableViewBottom])
  }

  
  @objc func dismissVC() {
    self.dismiss(animated: true, completion: nil)
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let query = textField.text else { return true }
    let options = ForwardGeocodeOptions(query: query)
    
    options.focalLocation = self.currentLocation
    options.allowedScopes = [.address, .landmark, .pointOfInterest]
    
    let task = geocoder.geocode(options) { (places, attributions, error) in
      guard let results = places else { return }
      
      self.searchResults = results
      self.tableView.reloadData()
    }
    
    return true
  }
}

extension DestinationViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell") as? SearchResultTableViewCell else { return UITableViewCell() }
    let result = searchResults[indexPath.row]
    
    let name = result.name
    let address = result.qualifiedName
    
    cell.title.text = name
    cell.subtitle.text = address
    
    return cell
  }
}

extension DestinationViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedLocation = searchResults[indexPath.row]
    
    let preview = PreviewViewController()
    preview.destination = selectedLocation
    preview.currentLocation = self.currentLocation
    
    navigationController?.pushViewController(preview, animated: false)
  }
}

//
//  SearchResultTableViewCell.swift
//  Pedi
//
//  Created by Isaac Rosenberg on 3/29/19.
//  Copyright © 2019 Isaac Rosenberg. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
  let title = UILabel()
  let subtitle = UILabel()
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addViews()
    constrain()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addViews() {
    title.translatesAutoresizingMaskIntoConstraints = false
    addSubview(title)
    
    subtitle.translatesAutoresizingMaskIntoConstraints = false
    addSubview(subtitle)
  }
  
  func constrain() {
    title.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
    title.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
    title.widthAnchor.constraint(equalTo: widthAnchor, constant: -30).isActive = true
    
    subtitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
    subtitle.widthAnchor.constraint(equalTo: widthAnchor, constant: -30).isActive = true
    subtitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}

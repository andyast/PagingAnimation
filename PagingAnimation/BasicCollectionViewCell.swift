//
//  BasicCollectionViewCell.swift
//  PagingAnimation
//
//  Created by Andy Steinmann on 11/21/14.

import UIKit

class BasicCollectionViewCell: UICollectionViewCell {
	@IBOutlet var number_label:UILabel?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.layer.cornerRadius = 3.0
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor.lightGrayColor().CGColor
    }

}

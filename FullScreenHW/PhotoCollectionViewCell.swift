//
//  PhotoCollectionViewCell.swift
//  FullScreenHW
//
//  Created by Joel Kopelioff on 7/27/15.
//  Copyright (c) 2015 Joel Kopelioff. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var videoPlayButton: UIButton!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        videoPlayButton.hidden = true
    }
}

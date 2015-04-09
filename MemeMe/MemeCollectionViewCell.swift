//
//  MemeCollectionViewCell.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// MemeCollectionViewCell
// represents cell of a collection view containing a single meme item.
//
class MemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var topLabel: UILabel?
    @IBOutlet weak var bottomLabel: UILabel?
    
    var meme: Meme? {
        didSet {
            if let meme = meme {
                if let imageView = imageView {
                    imageView.image = meme.image
                }
                if let topLabel = topLabel {
                    topLabel.text = meme.topText
                }
                if let bottomLabel = bottomLabel {
                    bottomLabel.text = meme.bottomText
                }
            }
        }
    }
    
}

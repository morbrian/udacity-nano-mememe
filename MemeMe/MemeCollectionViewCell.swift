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
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme? {
        didSet {
            if let meme = meme {
                imageView.image = meme.memedImage
            }
        }
    }

}

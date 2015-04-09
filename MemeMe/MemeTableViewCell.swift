//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/8/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// MemeTableViewCell
// represents cell of a collection view containing a single meme item.
//
class MemeTableViewCell: UITableViewCell {

    @IBOutlet weak var memeImageView: UIImageView?
    @IBOutlet weak var memeLabel: UILabel?
    
    var meme: Meme? {
        didSet {
            if let meme = meme {
                if let memeImageView = memeImageView {
                    memeImageView.image = meme.memedImage
                }
                if let memeLabel = memeLabel {
                    memeLabel.text = "\(meme.topText) \(meme.bottomText)"
                }
            }
        }
    }
}

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

    @IBOutlet weak var memeLabel: UILabel?
    @IBOutlet weak var memeImageView: UIImageView? {
        didSet {
            // the first time we get loaded we remember any backgroundColor
            // we might have configured in IB.
            if storeColorChange {
                originallyConfiguredColor = memeImageView?.backgroundColor
            }
        }
    }
    
    // the background color originally configured in IB.
    var originallyConfiguredColor: UIColor? {
        didSet {
            storeColorChange = false
        }
    }
    
    // whether or not to remember color changes to the UIIMageView background.
    private var storeColorChange = true
    
    var meme: Meme? {
        didSet {
            if let meme = meme {
                memeImageView?.image = meme.memedImage
                memeLabel?.text = "\(meme.topText) \(meme.bottomText)"
            }
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            memeImageView?.backgroundColor = originallyConfiguredColor
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            memeImageView?.backgroundColor = originallyConfiguredColor
        }
    }
}

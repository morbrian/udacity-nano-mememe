//
//  MemeItemsCollectionViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

class MemeItemsCollectionViewController: MemeItemsViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: UICollectionViewDataSource
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return memes.count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionItem", forIndexPath: indexPath) as MemeCollectionViewCell
            cell.meme = memes[indexPath.item]
            return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        showStaticViewerForMeme(memes[indexPath.item])
    }

    // MARK: Implement Abstract Overrides
    
    //
    // ask collectionview to reload data
    //
    override func reloadMemes() {
        collectionView.reloadData()
    }
    
}

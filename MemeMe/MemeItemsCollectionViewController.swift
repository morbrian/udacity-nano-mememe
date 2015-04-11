//
//  MemeItemsCollectionViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// MemeItemsCollectionViewController
// Displays Meme data in a tiled collection view.
//
class MemeItemsCollectionViewController: MemeItemsViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
    
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: UICollectionViewDataSource
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return memes?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionItem", forIndexPath: indexPath) as MemeCollectionViewCell
            cell.meme = memes?[indexPath.item]
            return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    //
    // On cell selection displays the static meme viewer.
    //
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         handleSelectionEventForMemeAtIndex(indexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        handleDeselectionEventForMemeAtIndex(indexPath.item)
    }
    
    // MARK: Implement Abstract Overrides
    
    //
    // ask collectionview to reload data
    //
    override func refreshMemesDisplay() {
        collectionView.reloadData()
    }
    
    override func editModeChanged() {
        collectionView?.allowsMultipleSelection = editMode
        if (!editMode) {
            let indexPaths = collectionView.indexPathsForSelectedItems()
            for indexPath in indexPaths {
                collectionView.deselectItemAtIndexPath(indexPath as? NSIndexPath, animated: true)
            }
            
        }
    }
    
    override func selectedMemes() -> [Meme] {
        return memesAtPaths(collectionView.indexPathsForSelectedItems() as? [NSIndexPath])
    }
}

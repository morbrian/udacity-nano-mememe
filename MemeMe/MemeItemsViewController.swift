//
//  MemeItemsViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/5/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// MemeItemsViewController
// Abstract Base class for our Meme Items controllers.
// Sub classses MUST override reloadMemes()
//
class MemeItemsViewController: UIViewController {
    
    var memes: [Meme]?
    var shouldSegueToEditor = false
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMemesFromSource()
        if let count = memes?.count {
            if count == 0 {
                shouldSegueToEditor = true
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadMemesFromSource()
        reloadMemes()
    }
    
    override func viewDidAppear(animated: Bool) {
        if shouldSegueToEditor {
            shouldSegueToEditor = false
            performSegueWithIdentifier("MemeEditorSegue", sender: self)
        }
    }
    
    // MARK: Helpers
    
    //
    // Instantiate viewcontroller with ID = MemeStaticViewer from storyboard.
    // Push with navigation controller to display.
    //
    func showStaticViewerForMeme(meme: Meme) {
        var singleMemeViewer = storyboard?.instantiateViewControllerWithIdentifier("MemeStaticViewer") as SingleMemeViewController
        singleMemeViewer.meme = meme
        navigationController?.pushViewController(singleMemeViewer, animated: true)
    }
    
    private func reloadMemesFromSource() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
    }
    
    // MARK: Abstract Methods
    
    //
    // subclasses should override to to perform appropriate actions when meme data needs to be reloaded.
    //
    func reloadMemes() {
        fatalError("This method must be overridden")
    }
    
}

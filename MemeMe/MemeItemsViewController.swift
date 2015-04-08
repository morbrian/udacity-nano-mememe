//
//  MemeItemsViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/5/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

class MemeItemsViewController: UIViewController {
    
    var memes: [Meme]!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
        reloadMemes()
    }
    
    // MARK: Helpers
    
    func showStaticViewerForMeme(meme: Meme) {
        var singleMemeViewer = storyboard?.instantiateViewControllerWithIdentifier("MemeStaticViewer") as SingleMemeViewController
        singleMemeViewer.meme = meme
        navigationController?.pushViewController(singleMemeViewer, animated: true)
    }
    
    // MARK: Abstract Methods
    
    //
    // subclasses should override to to perform appropriate actions when meme data needs to be reloaded.
    //
    func reloadMemes() {
        fatalError("This method must be overridden")
    }
    
}

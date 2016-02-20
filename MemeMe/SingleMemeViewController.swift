//
//  SingleMemeViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/6/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// SingleMemeViewController simply associates the meme object data
// with an ImageView for displayint the memed image.
// Supports tap gesture which will hide navbar and toolbar for full screen view.
//
// MARK: - SingleMemeViewController
class SingleMemeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
  
    var meme: Meme?
    
    override func viewDidLoad() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.addGestureRecognizer(tapRecognizer)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteMemeAction:")
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editMemeAction:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        imageView.image = meme?.memedImage
        // if the meme we are showing has been deleted since we last appeared,
        // we want to pop the display instead of showing the meme
        if let meme = meme {
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            if !appDelegate.memes.contains(meme) {
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    // MARK: Actions

    func deleteMemeAction(sender: AnyObject!) {
        if let meme  = meme {
            deleteMeme(meme)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    func editMemeAction(sender: AnyObject) {
        performSegueWithIdentifier("MemeEditorSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let editorVC = segue.destinationViewController as? MemeEditorViewController {
            editorVC.meme = meme
        }
    }
    
    // MARK: Gestures
    
    // When a user taps the view, hide the navigation bar and tabbar and animate background color change.
    func handleTap(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            if let navBarState = navigationController?.navigationBarHidden {
                navigationController?.setNavigationBarHidden(!navBarState, animated:true)
                // animate background color change
                UIView.animateWithDuration(0.35,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: { self.toggleBackGroundColor(!navBarState) },
                    completion: nil)
            }
            if let tabBarController = tabBarController {
                // animate tabbar hiding
                // TODO: this ends up feeling choppy as the UIImageView jumps into position at the end.
                UIView.transitionWithView(self.view,
                    duration: 0.35,
                    options: [UIViewAnimationOptions.LayoutSubviews, UIViewAnimationOptions.CurveEaseIn],
                    animations: { tabBarController.tabBar.hidden = !tabBarController.tabBar.hidden },
                    completion: nil)
            }
        }
    }
    
    // change background to black (true) or white (false)
    private func toggleBackGroundColor(state: Bool) {
        view.backgroundColor = state ? UIColor.blackColor() : UIColor.whiteColor()
    }
    
    // delete the meme
    private func deleteMeme(meme: Meme) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        if let index = appDelegate.memes.indexOf(meme) {
            appDelegate.memes.removeAtIndex(index)
        }
    }
    
}

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
//
class SingleMemeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
   
    var meme: Meme!
    
    override func viewDidLoad() {
        imageView.image = meme.memedImage
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.addGestureRecognizer(tapRecognizer)
    }
    
    //
    // When a user taps the view, hide the navigation bar and tabbar and animate background color change.
    //
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
            if let tabBarState = tabBarController?.tabBar.hidden {
                // animate tabbar hiding
                // TODO: this ends up feeling choppy as the UIImageView jumps into position at the end.
                UIView.transitionWithView(self.view,
                    duration: 0.35,
                    options: UIViewAnimationOptions.LayoutSubviews | UIViewAnimationOptions.CurveEaseIn,
                    animations: { self.tabBarController!.tabBar.hidden = !tabBarState },
                    completion: nil)
            }
        }
    }
    
    private func toggleBackGroundColor(state: Bool) {
        view.backgroundColor = state ? UIColor.blackColor() : UIColor.whiteColor()
    }
}

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
    
    // we only want to force the editor to show if the app opens to an empty list,
    // after the user browses around, cancels or deletes all items, we let them see the empty list.
    private var shouldSegueToEditor = false
    
    // mode permits interacting with the meme list
    var editMode: Bool = false {
        didSet {
            editModeChanged()
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = produceEditButton()
        navigationItem.rightBarButtonItem = produceAddMemeButton()
        reloadMemesFromSource()
        if let count = memes?.count {
            if count == 0 {
                shouldSegueToEditor = true
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if editMode {
            disableEditModeAction(self)
        }
        reloadMemesFromSource()
        refreshMemesDisplay()
        navigationItem.leftBarButtonItem?.enabled = memes?.count > 0
    }
    
    override func viewDidAppear(animated: Bool) {
        if shouldSegueToEditor {
            shouldSegueToEditor = false
            performSegueWithIdentifier("MemeEditorSegue", sender: self)
        }
    }
    
    // MARK: Actions
    
    func addMemeAction(sender: AnyObject!) {
        performSegueWithIdentifier("MemeEditorSegue", sender: self)
    }
    
    func enableEditModeAction(sender: AnyObject!) {
        editMode = true
        navigationItem.leftBarButtonItem = produceCancelButton()
        navigationItem.rightBarButtonItem = produceDeleteButton()
        navigationItem.rightBarButtonItem?.enabled = false
        editModeChanged()
    }
    
    func disableEditModeAction(sender: AnyObject!) {
        editMode = false
        navigationItem.leftBarButtonItem = produceEditButton()
        navigationItem.rightBarButtonItem = produceAddMemeButton()
        editModeChanged()
    }
    
    func deleteSingleMemeAtIndex(index: Int) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        appDelegate.memes.removeAtIndex(index)
        memes = appDelegate.memes
        refreshMemesDisplay()
    }

    func deleteSelectedMemesAction(sender: AnyObject!) {
        var selected = selectedMemes()
        if let newMemes = memes?.filter({ !contains(selected, $0) }) {
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as AppDelegate
            appDelegate.memes = newMemes
            memes = appDelegate.memes
            disableEditModeAction(self)
            refreshMemesDisplay()
        }
    }
    
    // MARK: Helpers
    
    //
    // Instantiate viewcontroller with ID = MemeStaticViewer from storyboard.
    // Push with navigation controller to display.
    //
    func handleSelectionEventForMemeAtIndex(index: Int) {
        if let memes = memes {
            if !editMode && index < memes.count {
                let meme = memes[index]
                var singleMemeViewer = storyboard?.instantiateViewControllerWithIdentifier("MemeStaticViewer") as SingleMemeViewController
                singleMemeViewer.meme = meme
                navigationController?.pushViewController(singleMemeViewer, animated: true)
            } else {
                selectionChanged()
            }
        }
    }
    
    func handleDeselectionEventForMemeAtIndex(index: Int) {
        if let memes = memes {
            if editMode {
                selectionChanged()
            }
        }
    }
    
    private func produceAddMemeButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMemeAction:")
    }
    
    private func produceEditButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "enableEditModeAction:")
    }
    
    private func produceCancelButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "disableEditModeAction:")
    }
    
    private func produceDeleteButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteSelectedMemesAction:")
    }
    
    private func reloadMemesFromSource() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
    }
    
    func memesAtPaths(indexPaths: [NSIndexPath]?) -> [Meme] {
        var result: [Meme] = [Meme]()
        if let indexPaths = indexPaths {
            if let memes = memes {
                result = indexPaths.map() { memes[$0.item] }
            }
        }
        return result
    }
    
    func selectionChanged() {
        if (editMode) {
            navigationItem.rightBarButtonItem?.enabled = selectedMemes().count > 0
        }
    }
    
    // MARK: Abstract Methods
    
    //
    // subclasses should override to to perform appropriate actions when meme data needs to be reloaded.
    //
    func refreshMemesDisplay() {
        fatalError("This method must be overridden")
    }
    
    //
    // subclasses should override to perform appropriate actions when edit mode is toggled
    //
    func editModeChanged() {
       fatalError("This method must be overridden")
    }
    
    //
    // return the list of selected memes
    //
    func selectedMemes() -> [Meme] {
        fatalError("This method must be overridden")
    }
    
}

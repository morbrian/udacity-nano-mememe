//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/5/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// MemeEditorViewController
// By far the most complex class of the application.
// Displays two editable text fields.
// Lets the user choose an image from the Camera or Photo Library
// Image is displayed full screen, and may be zoomed an panned behind the text.
// Share button permits user to post the image via device installed apps.
// Once Share is tapped, even tapping cancel will save the Meme in the list of memes.
//
class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    // MARK: Class Constants
    // FIX: class properties not yet supported in Swift, fix code when Swift supports.
    
    private let DefaultTop = "TOP"
    private let DefaultBottom = "BOTTOM"
    private let MemeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : CGFloat(-3.0)
    ]

    // MARK: Outlets and Properties
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.enabled = isSharingEnabled()
        }
    }
    
    // both private views set in viewDidLoad rather than storyboard
    // because it is simpler to configure these in code.
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    
    var meme: Meme? {
        didSet {
            shareButton.enabled = isSharingEnabled()
        }
    }
    
    // true if the lasted edited field was the bottom field, 
    // to help decided if we need to shift view when keyboard appears.
    private var bottomFieldLastEdited: Bool = false
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up textfield display properties
        configureTextField(topTextField)
        configureTextField(bottomTextField)
        
        // if no images are available, we'll display an empty imageview
        imageView = UIImageView()
        
        // scroll view will cover entire view, we expect to cover entire device display
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // imageview is only view contained by scrollview
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.addSubview(imageView)
        
        // we used storyboard to create toolbar but want the scrollview to render behind it
        view.insertSubview(scrollView, belowSubview: toolbar)
        
        scrollView.delegate = self
        
        // copy model or set default values for user inputs
        initializeDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayFromModel()
        
        scrollView.contentSize = imageView.bounds.size
        
        // disable camera button if not available, such as in simulator
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // register action if keyboard will show for either text field
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // unregister keyboard actions when view not showing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: View Display Preferences
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: User Actions
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        if let var meme = meme {
            meme.memedImage = generateMemedImage()
            if let memedImage = meme.memedImage {
                var activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
                activityViewController.completionWithItemsHandler = completeSharingActivity
                presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        pickImageFromSourceType(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        pickImageFromSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func cancelEditor(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIViewController Basics
    
    //
    // adjust zoom limites after device rotation
    //
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        setZoomParametersForSize(scrollView.bounds.size)
        recenterImage()
    }
    
    //
    // readjust zoom scale limits as necessary and recenter image as necessary
    //
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollView.bounds.size)
        recenterImage()
    }
    
    // MARK: TextField and Keyboard Handlers
    
    //
    // shift the entire view up if bottom text field being edited
    //
    func keyboardWillShow(notification: NSNotification) {
        if bottomFieldLastEdited {
            self.view.bounds.origin.y += getKeyboardHeight(notification)
            toolbar.hidden = true
        }
    }
    
    //
    // if bottom textfield just completed editing, shift the view back down
    //
    func keyboardWillHide(notification: NSNotification) {
        if bottomFieldLastEdited {
            view.bounds.origin.y -= getKeyboardHeight(notification)
            toolbar.hidden = false
        }
    }
    
    //
    // if textfield contains default text, clear text on start editing,
    // otherwise leave unmodified.
    //
    func textFieldDidBeginEditing(textField: UITextField) {
        bottomFieldLastEdited = textField == bottomTextField
        let text = textField.text
        if text == DefaultTop || text == DefaultBottom {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateModelFromDisplay()
    }
    
    //
    // remember the recently edited text field to allow
    // the keyboard hide event to decide if view needs to shift.
    //
    func textFieldShouldReturn(textField: UITextField) {
        textField.endEditing(false)
    }
    
    // MARK: UIScrollViewDelegate
    
    //
    // return our imageView as the target view for zoom gestures
    //
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        recenterImage()
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    //
    // set picked image and dismiss picker after user chooses image from source.
    //
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        imageView.image = image
        imageView.sizeToFit()
        imageView.frame.origin = CGPoint(x: 0.0, y: 0.0)
        scrollView.contentSize = imageView.bounds.size
        setZoomParametersForSize(scrollView.bounds.size)
        recenterImage()
        updateModelFromDisplay()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Private Helpers
    
    //
    // reset propery display to model values or defaults
    //
    private func initializeDisplay() {
        topTextField.text = meme?.topText ?? DefaultTop
        bottomTextField.text = meme?.bottomText ?? DefaultBottom
        imageView.image = meme?.image ?? imageView.image
    }
    
    //
    // modify the display to reflect values stored in model object
    //
    private func updateDisplayFromModel() {
        if let meme = self.meme {
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imageView.image = meme.image
        }
    }
    
    //
    // modify the model to reflect edits made by user in display
    //
    private func updateModelFromDisplay() {
        if meme == nil && isMemeCreateable() {
            // explicitly unwrapped imageView.image is verified as not nil by isMemeCreateable
            meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imageView.image!)
        } else {
            meme?.topText = topTextField.text
            meme?.bottomText = bottomTextField.text
            if let image = imageView.image {
                meme?.image = image
            }
        }
    }
    
    //
    // set font style, etc.. on textfield text
    //
    private func configureTextField(textField: UITextField) {
        textField.delegate = self
        // note that assigning the attributes resets the alignment, so it must come first.
        textField.defaultTextAttributes = MemeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
    }
    
    //
    // show the image picker for the requested source type
    //
    private func pickImageFromSourceType(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = sourceType
            picker.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    //
    // center the image. if the user has zoomed out past the height or width of the image,
    // then scale it back so there is no margin on any side of the image.
    //
    // Reference: rawwenderlich.com
    //
    private func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
        
    }
    
    //
    // configure zoom scales so that the content is restricted from zooming
    // beyond the point that would allow empty space on any side.
    //
    // Reference: rawwenderlich.com
    //
    private func setZoomParametersForSize(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale
        
        recenterImage()
    }
    
    //
    // return height of displayed keyboard
    //
    private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //
    // generate an image from the current view which is expected to be
    // the meme text overlayed on the image backgroud.
    //
    private func generateMemedImage() -> UIImage {
        let savedNavBarState = navigationController?.navigationBarHidden
        navigationController?.navigationBarHidden = true
        
        toolbar.hidden = true
        navbar.hidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolbar.hidden = false
        navbar.hidden = false
        
        return memedImage
    }
    
    //
    // evalute whether all requirements for meme creation have been met.
    // user must have modified both text fields and have picked an image before a meme can be created
    //
    private func isMemeCreateable() -> Bool {
        return topTextField.text != DefaultTop && bottomTextField.text != DefaultBottom && imageView.image != nil
    }
    
    //
    // sharing is enabled if complete meme data is available to create an new image
    //
    private func isSharingEnabled() -> Bool {
        return meme != nil
    }
    
    //
    // store the meme model
    //
    private func saveMeme() {
        if let meme = self.meme {
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as AppDelegate
            appDelegate.memes.append(meme)
        }
    }
    
    //
    // when sharing activity completes save meme then dismiss this editor,
    // returning to previous view on navigation stack.
    //
    private func completeSharingActivity(String!, Bool, [AnyObject]!, NSError!) {
        saveMeme()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

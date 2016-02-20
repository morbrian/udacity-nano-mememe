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
// Displays two editable text fields.
// Lets the user choose an image from the Camera or Photo Library
// Image is displayed full screen, and may be zoomed an panned behind the text.
// Share button permits user to post the image via device installed apps.
//
class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: Class Constants
    // FIX: class properties not yet supported in Swift, update code when Swift supports.
    
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
    @IBOutlet weak var shareButton: UIBarButtonItem? {
        didSet {
            shareButton?.enabled = isSharingEnabled()
        }
    }
    
    // both private views set in viewDidLoad rather than storyboard
    // because it is simpler to configure these in code.
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    
    var meme: Meme? {
        didSet {
            shareButton?.enabled = isSharingEnabled()
        }
    }
    
    // remember how far we moved the view after the keyboard displays
    private var viewShiftDistance: CGFloat? = nil

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
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // imageview is only view contained by scrollview
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.addSubview(imageView)
        
        // we used storyboard to create toolbar but want the scrollview to render behind it
        view.insertSubview(scrollView, belowSubview: toolbar)
        
        scrollView.delegate = self
        
        shareButton?.enabled = isSharingEnabled()
        
        // let tap cancel editing
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.addGestureRecognizer(tapRecognizer)
        
        // copy model or set default values for user inputs
        initializeDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayFromModel()
        layoutImageView()
        
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
    
    // MARK: Gestures
    func handleTap(sender: UIGestureRecognizer) {
        endTextEditing()
    }
    
    func endTextEditing() {
        topTextField?.endEditing(false)
        bottomTextField?.endEditing(false)
    }
    
    // MARK: User Actions
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        if let meme = meme {
            meme.memedImage = generateMemedImage()
            meme.scaledAndCroppedImage = generateMemedImage(true)
            if let memedImage = meme.memedImage {
                let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
                activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
                        if completed {
                            self.saveMeme()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                }
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
    
    // MARK: UIViewController Display Handling
    
    // adjust zoom limites after device rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        setZoomParametersForSize(scrollView.bounds.size)
    }
    
    // readjust zoom scale limits as necessary and recenter image as necessary
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollView.bounds.size)
        recenterWithScrollViewOrigin()
    }
    
    // adjust the image size for the current view size
    func layoutImageView() {
        imageView.sizeToFit()
        imageView.frame.origin = CGPoint(x: 0.0, y: 0.0)
        scrollView.contentSize = imageView.bounds.size
        setZoomParametersForSize(scrollView.bounds.size)
    }
    
    func recenterWithScrollViewOrigin() {
        // after views layout, center on the image.
        // this happens after picking an image and after device rotation.
        let imageViewSize = imageView.bounds.size
        let upperLeftCornerX = (imageViewSize.width * scrollView.zoomScale) / 2.0  - scrollView.bounds.size.width / 2.0
        let upperLeftCornerY = (imageViewSize.height * scrollView.zoomScale) / 2.0 - scrollView.bounds.size.height / 2.0
        scrollView.bounds.origin = CGPoint(x: upperLeftCornerX, y: upperLeftCornerY)
    }
    
    // MARK: Keyboard Handlers
    
    // shift the entire view up if bottom text field being edited
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.editing {
            var bottomOfField: CGFloat {
                let fieldOrigin =  view.convertPoint(bottomTextField.bounds.origin, fromView: bottomTextField)
                return fieldOrigin.y + bottomTextField.bounds.height
            }
            if viewShiftDistance == nil {
                let keyboardHeight = getKeyboardHeight(notification)
                let topOfKeyboard = view.bounds.maxY - keyboardHeight
                // we only need to move the view if the keyboard will cover up the login button and text fields
                if topOfKeyboard < bottomOfField {
                    viewShiftDistance = bottomOfField - topOfKeyboard
                    self.view.bounds.origin.y += viewShiftDistance!
                }
            }
            toolbar.hidden = true
        }
    }
    
    // if bottom textfield just completed editing, shift the view back down
    func keyboardWillHide(notification: NSNotification) {
        if let shiftDistance = viewShiftDistance {
            self.view.bounds.origin.y -= shiftDistance
            viewShiftDistance = nil
            toolbar.hidden = false
        }
    }
    
    // return height of displayed keyboard
    private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: Helpers
    
    // reset propery display to model values or defaults
    private func initializeDisplay() {
        topTextField.text = meme?.topText ?? DefaultTop
        bottomTextField.text = meme?.bottomText ?? DefaultBottom
        imageView.image = meme?.image ?? imageView.image
    }
    
    // modify the display to reflect values stored in model object
    private func updateDisplayFromModel() {
        if let meme = self.meme {
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imageView.image = meme.image
        }
    }
    
    // modify the model to reflect edits made by user in display
    private func updateModelFromDisplay() {
        if let topText = topTextField.text,
            bottomText = bottomTextField.text {
            if meme == nil && isMemeCreateable() {
                // explicitly unwrapped imageView.image is verified as not nil by isMemeCreateable
                meme = Meme(topText: topText, bottomText: bottomText, image: imageView.image!)
            } else {
                meme?.topText = topText
                meme?.bottomText = bottomText
                if let image = imageView.image {
                    meme?.image = image
                }
            }
        }
    }
    
    // set font style, etc.. on textfield text
    private func configureTextField(textField: UITextField) {
        textField.delegate = self
        // note that assigning the attributes resets the alignment, so it must come first.
        textField.defaultTextAttributes = MemeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
    }
    
    // show the image picker for the requested source type
    private func pickImageFromSourceType(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = sourceType
            picker.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    // configure zoom scales so that the content is restricted from zooming
    // beyond the point that would allow empty space on any side.
    //
    // Reference: rawwenderlich.com
    private func setZoomParametersForSize(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        // we get max of width or height so we always fill the screen
        let minScale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale
    }
    
    // generate an image from the current view which is expected to be
    // the meme text overlayed on the image backgroud.
    private func generateMemedImage(hideText: Bool = false) -> UIImage {
        navigationController?.navigationBarHidden = true
        
        toolbar.hidden = true
        navbar.hidden = true
        if hideText {
            topTextField.hidden = true
            bottomTextField.hidden = true
        }
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolbar.hidden = false
        navbar.hidden = false
        if hideText {
            topTextField.hidden = false
            bottomTextField.hidden = false
        }
        
        return memedImage
    }
    
    // evalute whether all requirements for meme creation have been met.
    // user must have modified both text fields and have picked an image before a meme can be created
    private func isMemeCreateable() -> Bool {
        return topTextField.text != DefaultTop && bottomTextField.text != DefaultBottom && imageView.image != nil
    }
    
    // sharing is enabled if complete meme data is available to create an new image
    private func isSharingEnabled() -> Bool {
        return meme != nil
    }
    
    // store the meme model
    private func saveMeme() {
        if let meme = self.meme {
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            if let index = appDelegate.memes.indexOf(meme) {
                appDelegate.memes.replaceRange(index...index, with: [meme])
            } else {
                appDelegate.memes.append(meme)
            }
            
        }
    }
    
}


// MARK: - UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate {

    // set picked image and dismiss picker after user chooses image from source.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            layoutImageView()
            updateModelFromDisplay()
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension MemeEditorViewController: UITextFieldDelegate {

    // if textfield contains default text, clear text on start editing,
    // otherwise leave unmodified.
    func textFieldDidBeginEditing(textField: UITextField) {
        let text = textField.text
        if text == DefaultTop || text == DefaultBottom {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateModelFromDisplay()
    }
    
    // remember the recently edited text field to allow
    // the keyboard hide event to decide if view needs to shift.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(false)
        return true
    }
}

// MARK: - UIScrollViewDelegate
extension MemeEditorViewController: UIScrollViewDelegate {

    // return our imageView as the target view for zoom gestures
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // while scrolling beyond the limits of the image, we like to keep it centered
        // so we adjust the insets.
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
}

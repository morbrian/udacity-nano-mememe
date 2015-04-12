# Udacity UIKit Fundamentals, Project-2 of iOS Nanodegree

This is my second project in the sequence of courses leading to the [iOS Developer Nanodegree from Udacity](https://www.udacity.com/course/nd003).

This intro document describes my implementation of the application and highlights some of the features I implemented that were not explicitly called out in the project specification.

## Table of Contents

* [App Launch](#app-launch)
* [Meme Editor View](#meme-editor-view)
* [Meme Table View](#meme-table-view)
* [Meme Collection View](#meme-collection-view)
* [Single Meme Viewer](#single-meme-viewer)
* [Known Issues](#known-issues)

## App Launch

When the application launches it checks whether there are any existing Memes.
If there are no Memes, it will present the user with the Meme Editor where a Meme can be created.

As there is no persistence in the MemeMe app, the app will always present the Editor on launch. However, if the app is not completely shutdown, such as by just hitting the home button, it will not present the editor again when the app is brought to the foreground again.

## Meme Editor View

The Meme Editor view is implemented with UIScrollView which permits the user to zoom and scale the background image beneath the Meme text.

* Tap the cancel button to return to previous view.
* Sharing a Meme requires both text fields and the image to be modified.
* Tap the share button to share the meme.
  * Tapping Cancel in the share activity means the meme will not be saved.

## Meme Table View

This is the first view on the tab controller. It presents a list of saved memes with images uniformly layed out on a gray backgound on the left.

* Tap a Meme item to see it full screen in the viewer.
* Swipe to the left on individual meme to reveal a delete button to delete it.
* Tap the "Edit" button to select multiple Meme items to delete.

## Meme Collection View

This is the second view on the tab controller. It presents a list of saved memes tiled across the screen in squares. The number of squares per row is calculated dynamically for the device size and orientation.

* Tap a Meme item to see it full screen in the viewer.
* Tap the "Edit" button to select multiple Meme items to delete.

## Singe Meme Viewer

This view is displayed after tapping a Meme item in the collection or table views. The meme is displayed at less than full screen within the top/bottom navigation bars, however tapping the image will animate it to full screen and change the background color from white to black.

* Tap image to make full screen.
* Tap Trash button to delete image.
* Tap Edit to transition to Meme Editor for editing the Meme data.
* Tap Sent Memes to return to the previous Meme list view.

## Known Issues

There are two features of the app which I was not able to completely address.  Both are due to my experimentation with UIScrollView, and neither interferes with the base level project requirements.

* Pinch-to-zoom or swipe-to-pan in Meme Editor does not work if the gesture begins on the UITextFields instead of on the background.
* Transitioning to the Meme Editor from an existing Meme will show the default centered full image view rather than reproduce the zoomed in or panned version that may have been set when the Meme was saved.

## References

In addition to the Udacity course content as the primary resource for this project, these are the additional resources used while creating the app. Supplemented further by many additional web searches. 

* [The Swift Programming Language](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/index.html)
* [Ray Wenderlich Tutorials](http://www.raywenderlich.com)
* [Developing iOS 8 Apps with Swift by Stanford](https://itunes.apple.com/us/course/developing-ios-8-apps-swift/id961180099)
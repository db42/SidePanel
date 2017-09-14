# SidePanel

[![CI Status](http://img.shields.io/travis/fulldecent/SidePanel.svg?style=flat)](https://travis-ci.org/fulldecent/SidePanel)
[![Version](https://img.shields.io/cocoapods/v/SidePanel.svg?style=flat)](http://cocoadocs.org/docsets/SidePanel)
[![License](https://img.shields.io/cocoapods/l/SidePanel.svg?style=flat)](http://cocoadocs.org/docsets/SidePanel)
[![Platform](https://img.shields.io/cocoapods/p/SidePanel.svg?style=flat)](http://cocoadocs.org/docsets/SidePanel)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<img src="Assets/sidepanel-demo-gif.gif" height="540" align="center"/>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Requirements


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate SidePanel into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'SidePanel'
```

Then, run the following command:

```bash
$ pod install
```


### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SidePanel into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "db42/SidePanel" ~> 0.6.1
```

Run `carthage update` to build the framework and drag the built `SidePanel.framework` into your Xcode project.

## Usage

```swift
//Override SidePanelController to provide a custom hamburger menu icon
class MySidePanelController: SidePanelController {
  override func leftButton() -> UIButton {
    let frame = CGRectMake(0, 0, 20, 20)
    let button = UIButton(frame: frame)
    button.setImage(UIImage(named: "menu"), forState: .Normal)
    return button
  }
}

//Initialise SidePanelController - AppDelegate.swift
var sidePanelController: SidePanelController?
var mainVC1: UINavigationController?
var mainVC2: UINavigationController?

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
  ....
  let mainVC1 = MainViewController()
  let sc = SideController()
  let sidePanelController = MySidePanelController(sideController: sc)
  sidePanelController.selectedViewController = mainVC1
  
  self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
  self.window?.rootViewController = svc
  self.window?.makeKeyAndVisible()
  self.sidePanelController = sidePanelController
  ....
}

//Handle navigation from SideController - SideViewController.swift
class SideViewController: UITableViewController {
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      let vc = indexPath.row == 0 ? appDelegate.mainVC1 : appDelegate.mainVC2
      appDelegate.sidePanelController?.selectedViewController = vc
    }
  }
}
```


## Author

Dushyant Bansal, dushyant37@gmail.com


## License

SidePanel is available under the MIT license. See the LICENSE file for more info.

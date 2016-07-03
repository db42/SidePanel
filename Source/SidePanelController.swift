//
//  SidePanelController.swift
//  SidePanel
//
//  Created by Dushyant Bansal on 25/06/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

public class SidePanelController: UIViewController, UIGestureRecognizerDelegate {
  
  public var selectedViewController: UIViewController? {
    didSet {
      guard oldValue != self.selectedViewController else {
        return
      }
      oldValue?.view.removeFromSuperview()
      oldValue?.willMoveToParentViewController(nil)
      oldValue?.removeFromParentViewController()
      updateSelectedViewcontroller()
    }
  }
  

  let sideController: UIViewController
  public var sidePanelWidth: CGFloat = 320.0
  
  private weak var sidePanelView: UIView!
  private weak var mainView: UIView?
  private weak var overlayMainView: UIView!
  private var hasLeftSwipeGestureStarted = false
  private var shouldHideSidePanel = false
  
  func updateSelectedViewcontroller() {
    let mainViewController = (selectedViewController as? UINavigationController)?.topViewController ?? selectedViewController
    if let navItem = mainViewController?.navigationItem where
      navItem.leftBarButtonItem == nil {
      let button = self.leftButton()
      button.addTarget(self, action: #selector(showSidePanel), forControlEvents: .TouchUpInside)
      navItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    if let svc = selectedViewController,
      mainView = self.mainView {
      addChildViewController(svc)
      mainView.addSubview(svc.view)
      svc.didMoveToParentViewController(self)
      hideSidePanel()
    }
  }
  
  public func leftButton() -> UIButton {
    let button = UIButton(type: .System)
    button.setTitle("Menu", forState: .Normal)
    return button
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    updateSelectedViewcontroller()

    addChildViewController(sideController)
    sideController.view.autoresizingMask = .None
    sideController.view.frame = sidePanelView.bounds
    sidePanelView.addSubview(sideController.view)
    sideController.didMoveToParentViewController(self)
    
    let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
    leftSwipeGesture.direction = .Left
    self.view.addGestureRecognizer(leftSwipeGesture)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    panGesture.delegate = self
    self.view.addGestureRecognizer(panGesture)
  }
  
  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if let _ = otherGestureRecognizer as? UISwipeGestureRecognizer {
      return true
    } else {
      return false
    }
  }
  
  func handlePan(panGestureRecognizer: UIPanGestureRecognizer)  {
    guard hasLeftSwipeGestureStarted == true else {
      return
    }
    
//    print(" \(panGestureRecognizer.state.rawValue), \(panGestureRecognizer.velocityInView(self.view).x)")
    
    let frame = sidePanelView.frame
    switch panGestureRecognizer.state {
    case .Changed:
      let panTranslation = panGestureRecognizer.translationInView(self.view)
      let speed = panGestureRecognizer.velocityInView(self.view).x
      if panTranslation.x <= 0 && abs(panTranslation.x) < frame.width {
        sidePanelView.frame = CGRectMake(panTranslation.x, frame.minY, frame.width, frame.height)
      }
      shouldHideSidePanel = abs(panTranslation.x) > sidePanelWidth/2 || speed < -75.0
      let alpha = 0.1 * (frame.width + frame.minX)/frame.width
      overlayMainView.alpha = alpha
    case .Ended:
      hasLeftSwipeGestureStarted = false
      shouldHideSidePanel ? hideSidePanel() : showSidePanel()
    default:
      break
    }
  }
  
  func hideSidePanel() {
    let frame = sidePanelView.frame
    UIView.animateWithDuration(0.4, animations: {
      self.sidePanelView.frame = CGRectMake(0 - frame.width, frame.minY, frame.width, frame.height)
      self.overlayMainView.alpha = 0
      }) { finished  in
      self.overlayMainView.hidden = true
    }
  }
  
  func showSidePanel() {
    let frame = sidePanelView.frame
    overlayMainView.hidden = false
    UIView.animateWithDuration(0.4) {
      self.sidePanelView.frame = CGRectMake(0, frame.minY, frame.width, frame.height)
      self.overlayMainView.alpha = 0.1
    }
  }
  
  func handleSwipeGesture(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.direction == .Left {
      hasLeftSwipeGestureStarted = true
      return
    } else {
      showSidePanel()
    }
  }

  public init(sideController: UIViewController) {
    self.sideController = sideController
    super.init(nibName: nil, bundle: NSBundle.mainBundle())
  }
  
  override public func loadView() {
    let view = UIView(frame: UIScreen.mainScreen().bounds)
    view.backgroundColor = UIColor.whiteColor()
    
    let mainView = UIView(frame: view.bounds)
    mainView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    view.addSubview(mainView)
    
    let overlayView = UIView(frame: view.bounds)
    overlayView.backgroundColor = UIColor.blackColor()
    overlayView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    overlayView.hidden = true
    view.addSubview(overlayView)
    
    let sideView = UIView(frame: CGRectMake(0 - sidePanelWidth, 0, sidePanelWidth, view.bounds.height))
    view.addSubview(sideView)
    
    self.mainView = mainView
    self.overlayMainView = overlayView
    sidePanelView = sideView
    self.view = view
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

//
//  https://github.com/db42/SidePanel
//
//  Copyright (c) 2016 Dushyant Bansal
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public class SidePanelController: UIViewController, UIGestureRecognizerDelegate {
  
  public var selectedViewController: UIViewController? {
    didSet {
      guard oldValue != self.selectedViewController else {
        hideSidePanel()
        return
      }
      oldValue?.view.removeFromSuperview()
      oldValue?.willMove(toParent: nil)
      oldValue?.removeFromParent()
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
    if let navItem = mainViewController?.navigationItem, navItem.leftBarButtonItem == nil {
      let button = self.leftButton()
      button.addTarget(self, action: #selector(showSidePanel), for: .touchUpInside)
      navItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    if let svc = selectedViewController, let mainView = self.mainView {
      addChild(svc)
      mainView.addSubview(svc.view)
      svc.didMove(toParent: self)
      hideSidePanel()
    }
  }
  
  public func leftButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle("Menu", for: .normal)
    return button
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    updateSelectedViewcontroller()
    
    addChild(sideController)
    sideController.view.autoresizingMask = []
    sideController.view.frame = sidePanelView.bounds
    sidePanelView.addSubview(sideController.view)
    sideController.didMove(toParent: self)
    
    let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
    leftSwipeGesture.direction = .left
    self.view.addGestureRecognizer(leftSwipeGesture)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    panGesture.delegate = self
    self.view.addGestureRecognizer(panGesture)
  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if let _ = otherGestureRecognizer as? UISwipeGestureRecognizer {
      return true
    } else {
      return false
    }
  }
  
  @objc func handlePan(panGestureRecognizer: UIPanGestureRecognizer)  {
    guard hasLeftSwipeGestureStarted == true else {
      return
    }
    
    //    print(" \(panGestureRecognizer.state.rawValue), \(panGestureRecognizer.velocityInView(self.view).x)")
    
    let frame = sidePanelView.frame
    switch panGestureRecognizer.state {
    case .changed:
      let panTranslation = panGestureRecognizer.translation(in: self.view)
      let speed = panGestureRecognizer.velocity(in: self.view).x
      if panTranslation.x <= 0 && abs(panTranslation.x) < frame.width {
        sidePanelView.frame = CGRect(x: panTranslation.x, y: frame.minY, width: frame.width, height: frame.height)
      }
      shouldHideSidePanel = abs(panTranslation.x) > sidePanelWidth/2 || speed < -75.0
      let alpha = 0.1 * (frame.width + frame.minX)/frame.width
      overlayMainView.alpha = alpha
    case .ended:
      hasLeftSwipeGestureStarted = false
      shouldHideSidePanel ? hideSidePanel() : showSidePanel()
    default:
      break
    }
  }
  
  @objc func hideSidePanel() {
    let frame = sidePanelView.frame
    UIView.animate(withDuration: 0.4, animations: {
      self.sidePanelView.frame = CGRect(x: 0 - frame.width, y: frame.minY, width: frame.width, height: frame.height)
      self.overlayMainView.alpha = 0
    }) { finished  in
      self.overlayMainView.isHidden = true
    }
  }
  
  @objc func showSidePanel() {
    let frame = sidePanelView.frame
    overlayMainView.isHidden = false
    UIView.animate(withDuration: 0.4) {
      self.sidePanelView.frame = CGRect(x: 0, y: frame.minY, width: frame.width, height: frame.height)
      self.overlayMainView.alpha = 0.1
    }
  }
  
  @objc func handleSwipeGesture(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.direction == .left {
      hasLeftSwipeGestureStarted = true
      return
    } else {
      showSidePanel()
    }
  }
  
  public init(sideController: UIViewController) {
    self.sideController = sideController
    super.init(nibName: nil, bundle: Bundle.main)
  }
  
  override public func loadView() {
    let view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = UIColor.white
    
    let mainView = UIView(frame: view.bounds)
    mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(mainView)
    
    let overlayView = UIView(frame: view.bounds)
    overlayView.backgroundColor = UIColor.black
    overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    overlayView.isHidden = true
    view.addSubview(overlayView)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSidePanel))
    overlayView.addGestureRecognizer(tapGesture)
    
    let sideView = UIView(frame: CGRect(x: 0 - sidePanelWidth, y: 0, width: sidePanelWidth, height: view.bounds.height))
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

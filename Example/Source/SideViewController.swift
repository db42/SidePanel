//
//  SideViewController.swift
//  SidePanel
//
//  Created by Dushyant Bansal on 28/06/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

class SideViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      let vc = indexPath.row == 0 ? appDelegate.vc1 : appDelegate.vc2
      appDelegate.sidePanelController?.selectedViewController = vc
    }
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

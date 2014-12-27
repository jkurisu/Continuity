//
//  ConnectionsViewController.swift
//  Continuity
//
//  Created by Jon Kurisu on 12/26/14.
//  Copyright (c) 2014 AOTO Systems, Inc. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConnectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MCBrowserViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var visibleSwitch: UISwitch!
    
    @IBOutlet weak var disconnectButton: UIButton!
    
    @IBOutlet weak var connectedDevicesTableView: UITableView!
    
    var appDelegate: AppDelegate?
    
    var connectedDevices: [String] = []
    
    @IBAction func browseForDevices(sender: AnyObject) {
        println("browseForDevices")
        appDelegate?.mcManager?.setupMCBrowser()
        appDelegate?.mcManager?.browser?.delegate = self
        presentViewController(appDelegate!.mcManager!.browser!, animated: true, completion: nil)
    }
    
    @IBAction func disconnect(sender: AnyObject) {
        println("disconnect")
        appDelegate?.mcManager?.session?.disconnect()
        nameTextField.enabled = true
        connectedDevices.removeAll(keepCapacity: true)
        connectedDevicesTableView.reloadData()
    }
    
    @IBAction func toggleVisibility(sender: AnyObject) {
        appDelegate?.mcManager?.advertiseSelf(visibleSwitch.on)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        appDelegate?.mcManager?.peerId = nil
        appDelegate?.mcManager?.session = nil
        appDelegate?.mcManager?.browser = nil
        
        if visibleSwitch.on {
            appDelegate?.mcManager?.advertiser?.stop()
        }
        appDelegate?.mcManager?.advertiser = nil
        
        appDelegate?.mcManager?.setupPeerAndSessionWithDisplayName(nameTextField.text)
        appDelegate?.mcManager?.setupMCBrowser()
        appDelegate?.mcManager?.advertiseSelf(visibleSwitch.on)
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.mcManager?.setupPeerAndSessionWithDisplayName(UIDevice.currentDevice().name)
        appDelegate?.mcManager?.advertiseSelf(visibleSwitch.on)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerDidChangeStateWithNotification:", name: "MCDidChangeStateNotification", object: nil)
        
    }

    
    func peerDidChangeStateWithNotification(notification: NSNotification) {
        var info = notification.userInfo!
        var peerId = info["peerID"] as MCPeerID
        
        let peerDisplayName = peerId.displayName
        
        var state = info["state"] as Int   // Need a MCSessionState not an Int
        let sessionState = MCSessionState(rawValue: state)
        
        
        if sessionState != MCSessionState.Connecting {
            if sessionState == MCSessionState.Connected {
                connectedDevices.append(peerDisplayName)
            } else if sessionState == MCSessionState.NotConnected {
                if connectedDevices.count > 0 {
                    if let i = find(connectedDevices, peerDisplayName) {
                        connectedDevices.removeAtIndex(i)
                    }
                }
            }
            connectedDevicesTableView.reloadData()
            let peersExist = appDelegate?.mcManager?.session?.connectedPeers.count == 0
            disconnectButton.enabled = !peersExist
            nameTextField.enabled = peersExist
        }
        
        
//        MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
//        NSString *peerDisplayName = peerID.displayName;
//        MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
//        
//        if (state != MCSessionStateConnecting) {
//            if (state == MCSessionStateConnected) {
//                [_arrConnectedDevices addObject:peerDisplayName];
//            }
//            else if (state == MCSessionStateNotConnected){
//                if ([_arrConnectedDevices count] > 0) {
//                    int indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
//                    [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
//                }
//            }
//            [_tblConnectedDevices reloadData];
//        
//            BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
//            [_btnDisconnect setEnabled:!peersExist];
//            [_txtName setEnabled:peersExist];

//        }
//            [_tblConnectedDevices reloadData];
//            BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
//            [_btnDisconnect setEnabled:!peersExist];
//            [_txtName setEnabled:peersExist];
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellIdentifier")
        }
        cell?.textLabel?.text = connectedDevices[indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate?.mcManager?.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate?.mcManager?.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewController(browserViewController: MCBrowserViewController!, shouldPresentNearbyPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) -> Bool {
        println("shouldPresentNearbyPeer")
        return false
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

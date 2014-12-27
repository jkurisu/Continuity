//
//  ChatViewController.swift
//  Continuity
//
//  Created by Jon Kurisu on 12/27/14.
//  Copyright (c) 2014 AOTO Systems, Inc. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController, UITextFieldDelegate {

    var appDelegate: AppDelegate?
   
    @IBOutlet weak var chatTextView: UITextView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func cancelMessage(sender: AnyObject) {
        messageTextField.resignFirstResponder()
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        sendMyMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.delegate = self
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "MCDidReceiveDataNotification", object: nil)

    }
    
    func didReceiveDataWithNotification(notification: NSNotification) {
        var info = notification.userInfo!
        var peerId = info["peerID"] as MCPeerID
        
        let peerDisplayName = peerId.displayName
        
        var receivedData = info["data"] as NSData
        
        let receivedText = NSString(data: receivedData, encoding: NSUTF8StringEncoding)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.chatTextView.text = self.chatTextView.text + "\(peerDisplayName) wrote: \n\(receivedText)\n\n"
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendMyMessage()
        return true
    }
    
    
    private func sendMyMessage() {
        var dataToSend = messageTextField.text.dataUsingEncoding(NSUTF8StringEncoding)
        var allPeers = appDelegate?.mcManager?.session?.connectedPeers
        var error: NSError?  = nil
        appDelegate?.mcManager?.session?.sendData(dataToSend, toPeers: allPeers, withMode: .Reliable, error: &error)
        if error != nil {
            println(error)
        }
        
        var chat = chatTextView.text
        
        chatTextView.text = chat + "I wrote: \n\(messageTextField!.text)\n\n"
        messageTextField.text = ""
        messageTextField.resignFirstResponder()
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

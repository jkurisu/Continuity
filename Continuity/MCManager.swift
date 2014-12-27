//
//  MCManager.swift
//  Continuity
//
//  Created by Jon Kurisu on 12/26/14.
//  Copyright (c) 2014 AOTO Systems, Inc. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MCManager: NSObject, MCSessionDelegate {
    
    let SERVICE_TYPE = "chat-files"
    
    var peerId: MCPeerID?
    var session: MCSession?
    var browser: MCBrowserViewController?
    var advertiser: MCAdvertiserAssistant?
    
    override init() {
        super.init()
    }
    
    func setupPeerAndSessionWithDisplayName(displayName: String) {
        peerId = MCPeerID(displayName: displayName)
        session = MCSession(peer: peerId)
        session!.delegate = self;
    }
    
    func setupMCBrowser() {
        browser = MCBrowserViewController(serviceType: SERVICE_TYPE, session: session)
    }
    
    func advertiseSelf(shouldAdvertise: Bool) {
        if shouldAdvertise {
            advertiser = MCAdvertiserAssistant(serviceType: SERVICE_TYPE, discoveryInfo: nil, session: session)
            println("\(shouldAdvertise):\(advertiser)")
            advertiser!.start()
        } else {
            println("\(shouldAdvertise):\(advertiser)")
            advertiser!.stop()
            advertiser = nil
        }
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("didChangeState: \(session):\(peerID):\(state)")
        var dict: [String: AnyObject] = ["peerID": peerID, "state": String(state.rawValue)]
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dict)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("didReceiveData: \(session):\(data):\(peerID)")
        let dict = ["peerID": peerID, "data": data]
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidReceiveDataNotification", object: nil, userInfo: dict)
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
   
}

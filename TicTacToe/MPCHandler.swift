//
//  MPCHandler.swift
//  TicTacToe
//
//  Created by Mishana on 13.09.2023.
//

import UIKit
import MultipeerConnectivity

class MPCHandler: NSObject, MCNearbyServiceAdvertiserDelegate {
    
    
    
    
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        <#code#>
//    }
    
    
    var peerID:MCPeerID!
    var session:MCSession!
    var browser: MCBrowserViewController!
//    var browser: MCNearbyServiceBrowser!
//    var advertiser: MCAdvertiserAssistant?  = nil
    var advertiser: MCNearbyServiceAdvertiser!
    
    func setupPeerWithDisplayName(displayName: String ) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession() {
//        session = MCSession(peer: peerID)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    func setupBrowser() {
        browser = MCBrowserViewController(serviceType: "game", session: session)
//        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "game")
    }
    
    func advertiseSelf(advertise: Bool) {
        if advertise {
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "game")
            advertiser.delegate = self
            advertiser.startAdvertisingPeer()
//            advertiser.delegate = self advertiser?.startAdvertisingPeer()
//            advertiser = MCAdvertiserAssistant(serviceType: "game", discoveryInfo: nil, session: session)
//            advertiser!.start()
        }else{
            self.advertiser.stopAdvertisingPeer()
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MPCHandler: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
        let userInfo: [String:Any] = ["peerID":peerID,"state": state.rawValue]//
        DispatchQueue.main.async { () -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil, userInfo: userInfo)
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let userInfo: [String:Any] = ["data":data, "peerID":peerID]
        DispatchQueue.main.async { () -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidReceiveNotification"), object: nil, userInfo: userInfo)
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        
    }
    
    
}

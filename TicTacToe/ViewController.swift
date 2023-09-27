//
//  ViewController.swift
//  TicTacToe
//
//  Created by Mishana on 07.08.2023.
//

import UIKit
import MultipeerConnectivity

final class ViewController: UIViewController {

    @IBOutlet private var collection: [TTTImageView]!
    private var currentPlayer: String!
    private var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension ViewController {
    
    func setup() {
        view.backgroundColor = .white
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(advertise: true)
        setupField()
        currentPlayer = "x"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.peerChangeStateWithNotification(notification:)), name: NSNotification.Name("MPC_DidChangeStateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRecivedDataWithNotification(notification:)), name: NSNotification.Name("MPC_DidReceiveNotification"), object: nil)
    }
    
    func setupField() {
        for index in 0..<collection.count {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.fieldTapped))
            gestureRecognizer.numberOfTapsRequired = 1
            
            collection[index].addGestureRecognizer(gestureRecognizer)
        }
    }
}

extension ViewController {
    @objc func peerChangeStateWithNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo
        
        let state: Int? = userInfo?["state"] as? Int
        if state != MCSessionState.connecting.rawValue {
            self.navigationItem.title = "Connected"
        }
    }
    
    @objc func handleRecivedDataWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo
        
        guard let recivedData: Data = userInfo?["data"] as? Data else {return}
        guard let senderPeerID: MCPeerID = userInfo?["peerID"] as? MCPeerID else {return}
        let senderDisplayName = senderPeerID.displayName
        do {
            let message = try JSONSerialization.jsonObject(with: recivedData as Data, options: .allowFragments) as? [String: Any]
            guard let newValue = message as? [String: Any] else {return}
            let field: Int = newValue["field"] as! Int
            
            let player: String = newValue["player"] as! String
            
            if  field != nil && player != nil {
                collection[field].setPlayer(player)
                
                if player == "x"{
                    currentPlayer = "o"
                } else {
                    currentPlayer = "x"
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        checkResults()
    }
    
    @objc func fieldTapped(recognizer: UIGestureRecognizer) {
        let tappedField = recognizer.view as? TTTImageView
        tappedField?.setPlayer(currentPlayer)
        
        let messageDict: [String: Any] = ["field": tappedField?.tag ,"player": currentPlayer ]
        do {
            let messageData = try JSONSerialization.data(withJSONObject: messageDict, options: .prettyPrinted)
            
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }catch let error {
            print("Error: \(error.localizedDescription)")
        }
        checkResults()
    }
    
    @IBAction func connectWithPlayer(_ sender: Any) {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
            
        }
    }
    
}

extension ViewController {
    func checkResults() {
        var winer = ""
        
        if  collection[0].player == "x" && collection[1].player == "x" && collection[2].player == "x" ||
            collection[3].player == "x" && collection[4].player == "x" && collection[5].player == "x" ||
            collection[6].player == "x" && collection[7].player == "x" && collection[8].player == "x" ||
            collection[0].player == "x" && collection[4].player == "x" && collection[8].player == "x" ||
            collection[2].player == "x" && collection[4].player == "x" && collection[6].player == "x" ||
            collection[0].player == "x" && collection[3].player == "x" && collection[6].player == "x" ||
            collection[1].player == "x" && collection[4].player == "x" && collection[7].player == "x" ||
            collection[2].player == "x" && collection[5].player == "x" && collection[8].player == "x" {
            winer = "x"
        } else if
            collection[0].player == "o" && collection[1].player == "o" && collection[2].player == "o" ||
            collection[3].player == "o" && collection[4].player == "o" && collection[5].player == "o" ||
            collection[6].player == "o" && collection[7].player == "o" && collection[8].player == "o" ||
            collection[0].player == "o" && collection[4].player == "o" && collection[8].player == "o" ||
            collection[2].player == "o" && collection[4].player == "o" && collection[6].player == "o" ||
            collection[0].player == "o" && collection[3].player == "o" && collection[6].player == "o" ||
            collection[2].player == "o" && collection[4].player == "o" && collection[7].player == "o" ||
            collection[2].player == "o" && collection[5].player == "o" && collection[8].player == "o" {
            winer = "o"
        }else if
            collection[0].player != nil && collection[1].player != nil && collection[2].player != nil &&
            collection[3].player != nil && collection[4].player != nil && collection[5].player != nil &&
            collection[6].player != nil && collection[7].player != nil && collection[8].player != nil {
            winer = "Nobody"
        }
        
        if winer != "" {
            
            let alert = UIAlertController(title: "Tic Tac Toe", message: "The winner \(winer)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in}))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true)
    }
}



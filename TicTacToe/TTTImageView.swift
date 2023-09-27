//
//  TTTImageView.swift
//  TicTacToe
//
//  Created by Mishana on 13.09.2023.
//

import UIKit

final class TTTImageView: UIImageView {

    private var activated: Bool! = false
    var player: String?
    
    func setPlayer(_ player: String ){
        self.player = player
        
        if activated == false {
            if player == "x" {
                self.image = UIImage(systemName: "multiply")
            } else if player == "o" {
                self.image = UIImage(systemName: "circle")
            }
            activated = true
        }
    }
}

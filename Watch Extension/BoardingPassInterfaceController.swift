//
//  BoardingPassInterfaceController.swift
//  AirAber
//
//  Created by shashi kumar on 16/06/16.
//  Copyright © 2016 Mic Pringle. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class BoardingPassInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var originLabel: WKInterfaceLabel!
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    @IBOutlet var boardingPassImage: WKInterfaceImage!
    var flight: Flight? {
        didSet {
            if let flight = flight {
                originLabel.setText(flight.origin)
                destinationLabel.setText(flight.destination)
                if let _ = flight.boardingPass {
                    showBoardingPass()
                }
            }
        }
    }
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    private func showBoardingPass() {
        boardingPassImage.stopAnimating()
        boardingPassImage.setWidth(120)
        boardingPassImage.setHeight(120)
        boardingPassImage.setImage(flight?.boardingPass)
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let flight = context as? Flight { self.flight = flight }
    }
    
    override func didAppear() {
        super.didAppear()
        // 1
        if let flight = flight where flight.boardingPass == nil && WCSession.isSupported() {
            // 2
            session = WCSession.defaultSession()
            // 3
            session!.sendMessage(["reference": flight.reference], replyHandler: { (response) -> Void in
                // 4
                if let boardingPassData = response["boardingPassData"] as? NSData, boardingPass = UIImage(data: boardingPassData) {
                    // 5
                    flight.boardingPass = boardingPass
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showBoardingPass()
                    })
                }
                }, errorHandler: { (error) -> Void in
                    // 6
                    print(error)
            })
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

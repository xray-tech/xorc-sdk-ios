//
//  ViewController.swift
//  XraySampleApp
//
//  Created by Jan Chaloupecky on 30.05.18.
//  Copyright © 2018 360dialog. All rights reserved.
//

import UIKit
import XrayKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Xray.events.register(transmitter: LogTransmitter())
        
        
    }
    
    @IBAction func eventButtonAction(sender: Any) {
        
        let event = Event(name: "my_event", properties: [
            "foo": JSONValue("bar"),
            "date": JSONValue(1.1)])
        Xray.events.log(event: event)
    }
}

public class LogTransmitter: EventTransmitter {
    
    public init() {
        
    }
    
    public func transmit(events: [Event], completion: @escaping (EventResult) -> Void) {
        for event in events {
            print("Debug Transmitting event \(event)")
        }
    }
}

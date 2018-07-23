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
        
        Xray.events.register(transmitter: MockTrasnmitter(behaviour: .retry(nextRetryAt: Date())))
        
        
        Xray.data.onTrigger = { payloads in
            
            guard let payload = payloads.first else { return }
            
            if let myData = String(data: payload.data, encoding: .utf8) {
                
                let controller = UIAlertController(title: "Data received", message: myData, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                    self.dismiss(animated: true)
                })
                
                self.present(controller, animated: true)
            }
        }
    }
    
    @IBAction func eventButtonAction(sender: Any) {
        
        let context: [String: JSONValue] = [
            "session_id": "hello",
            "retry": true,
            "retryAt": JSONValue(Date().timeIntervalSince1970)
        ]
        
        // Send the event
        let event = Event(name: "purchase", properties: ["item_name": "iPhone"], context: context)
        Xray.events.log(event: event)
    }
    
    @IBAction func scheduleButtonAction(sender: Any) {
        
        
        // Create an event trigger with event properties
        let eventTrigger = EventTrigger(name: "purchase", filters: [ "event.properties.item_name": ["in": ["iPhone", "iPad"]] ])
        
        // Schedule the trigger until the event occurs
        Xray.data.schedule(payload: DataPayload(data: "Hello".data(using: .utf8)!, trigger: .event(eventTrigger)))
        
    }
}

class MockTrasnmitter: EventTransmitter {
    
    enum MockBehaviour {
        case succeed
        case retry(nextRetryAt: Date)
        case fail
        case none // dont call the completion at all
    }
    
    let behaviour: MockBehaviour
    
    init(behaviour: MockBehaviour = .none) {
        self.behaviour = behaviour
    }
    
    var events = [Event]()
    
    
    func transmit(events: [Event], completion: @escaping ([EventResult]) -> Void) {
        self.events += events
        
        var behaviour = self.behaviour
        if let context = events.first?.context {
            if
                let fail = context["retry"]?.boolValue, fail == true,
                let retryAt = context["retryAt"]?.doubleValue
            {
                behaviour = .retry(nextRetryAt: Date(timeIntervalSince1970: retryAt))
            }
        }
        
        switch behaviour {
        case .succeed:
            completion(events.map { .success(event: $0) })
        case .retry(let nextRetryAt):
            completion(events.map { .retry(event: $0, nextRetryAt: nextRetryAt) })
        case .fail:
            completion(events.map { .failure(event: $0) })
        case .none: break
        }
    }
}

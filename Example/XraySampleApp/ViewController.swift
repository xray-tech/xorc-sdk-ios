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
        
        
    }
    
    func hello() -> String {
        return "Hello"
    }
    
    @IBAction func eventButtonAction(sender: Any) {
        
        let properties: [String: JSONValue] = [
            "foo": "bar",
            "float": 1.1]
        
        let context: [String: JSONValue] = [
            "session_id": "hello",
            "retry": true,
            "retryAt": JSONValue(Date().timeIntervalSince1970)
        ]
        
        let event = Event(name: "my_event", properties: properties, context: context)
        
        Xray.events.log(event: event)
    }

    @IBAction func scheduleButtonAction(sender: Any) {
        
        let filters = """
                {"event.properties.item_name":{"eq":"iPhone"}}
                """
        
        // todo this optional API is not easy to use
        if let eventTrigger = try? EventTrigger(name: "my_event", jsonFilters: filters) {
            let trigger = DataPayload.Trigger.event(eventTrigger)
            let data = "Hello".data(using: .utf8)!
            
            let payload = DataPayload(data: data, trigger: trigger)
            
            Xray.data.schedule(payload: payload)
        }
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

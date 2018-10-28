

# XrayKit iOS



![badge-languages] ![badge-pms]

## Introduction


The XrayKit is a mobile SDK that offers event driven communication with the real time Xray backend. The main benefits for mobile applications from this SDK are

- Deliver user and application events
- Receive data in real time in response to those events
- Remotely setup local triggers to deliver data instantly even offline


Among others, the XrayKit can be used as a base SDK for mobile marketing SDK leeraging the non business logic features.

XrayKit is meant to be network trasnport and api protocol agnostic. This means that *how* the events are sent or *how* that data are received can be implemented for scenarios where MQTT or WebSockets are prefered over a HTTP protocol. The default implementation is provided to allow the communication with the Xray backend via HTTP. 

See [Architecture](#architecture) for further information about the SDK


## Installation

> _Note:_ XrayKit requires Swift 4.2 and Xcode] 10.0

### Carthage

[Carthage][] is a simple, decentralized dependency manager for Cocoa. To
install SQLite.swift with Carthage:

 1. Make sure Carthage is [installed][Carthage Installation].

 2. Update your Cartfile to include the following:

    ```ruby
    github "xray-tech/xorc-sdk-ios" ~> 1.0
    ```

 3. Run `carthage update` and
    [add the appropriate framework][Carthage Usage].


[Carthage]: https://github.com/Carthage/Carthage
[Carthage Installation]: https://github.com/Carthage/Carthage#installing-carthage
[Carthage Usage]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### CocoaPods

[CocoaPods][] is a dependency manager for Cocoa projects. To install
SQLite.swift with CocoaPods:

 1. Make sure CocoaPods is [installed][CocoaPods Installation]. (XrayKit
    requires version 1.0.0 or greater.)

    ```sh
    # Using the default Ruby install will require you to use sudo when
    # installing and updating gems.
    [sudo] gem install cocoapods
    ```

 2. Update your Podfile to include the following:

    ```ruby
    use_frameworks!

    target 'YourAppTargetName' do
        pod 'XrayKit', '~> 1.0'
    end
    ```

 3. Run `pod install --repo-update`.

[CocoaPods]: https://cocoapods.org
[CocoaPods Installation]: https://guides.cocoapods.org/using/getting-started.html#getting-started


## Usage 
### Starting the SDK

### Events

#### Simple Events
Sending a simple event with properties

```swift
let event = Event(name: "purchase", properties: [
    "item_name": "iPhoneX",
    "item_price": 1149
    ]
)
    
Xray.events.log(event: event)
```

#### Events with context
You can assing a context to each event. The context is not used for any data triggers but are handed back to you when the even triggers data (more on that later) 

```swift
// Send a simple event with properties and context
    
// optional properties related to the event
let properties: [String: JSONValue] = [ "item_name": "iPhoneX", "item_price": 1149]
    
// optional context in which the event was triggered.
let context: [String: JSONValue] = ["test_device": true]
    
Xray.events.log(event: Event(name: "purchase", properties: properties, context: context))
```

**Local events**

You can emmit events that are local which means that they will not be send over the network. The use case if you want to emmit events containing sensitive data that must not leave the device.

```swift
let event = Event(name: "did_join_wifi", properties: ["ssid": "home wlan"], context: nil, scope: .local)
Xray.events.log(event: event)

```


### Data Triggers


#### Reacting to triggered data 

The XrayKit can react on emmited events by delivering data back to you. *What* the data are and what is their meaning is to be defined by you. The XrayKit simply delivers to you "at the right time".

In the following example we simply log the data as String

```swift
Xray.data.onTrigger = { (payloads: [DataPayload]) in
    
    payloads.forEach { (payload: DataPayload) in
        if let myData = String(data: payload.data, encoding: .utf8) {
            print("Received data \(myData)")
        }
    }
}
```

An marketing implementation could expect a data as a JSON and present an InApp message. In the following example, the `InAppMessage` is a fictive struct that holds the required fields to display a message to a user.

```swift
struct InAppMessage: Decodable {
    enum CloseButtonPosition: String, Decodable {
        case topLeft
        case topRight
        case boomLeft
        case bottomRight
    }
    let url: URL
    let closeButtonPosition: CloseButtonPosition
}
        
Xray.data.onTrigger = { payloads in
    
    let decoder = JSONDecoder()
    guard
        let data = payloads.first?.data,
        let inAppMessage = try? decoder.decode(InAppMessage.self, from: data) else {  return }

    // handle the presentation to the user
    present(inAppMessage: inAppMessage)
}
```

#### Setting up data triggers

The Xray backend rule engine decides remotely when to deliver the data to the XrayKit. The default implementation uses the APNS silent message to push the `DataPayload` so all you need to do is the implement the above `onTrigger` callback.

You can setup `DataTriggers` manually using the `DataPayload.Trigger`. An `EventTrigger` has an event name and a list of filters. Both are stored locally by the XrayKit and matched agains all occuring events. If an event with a matching name amd properties matches, the DataPayload is delivered in the `onTrigger` callback.

You can use any operators supported by `NSPredicate` to used with the event properties:


```swift
// Create an event trigger that matches a "pruchase" event with an "item_name" either equal to "iPad" or "iPhoneX
let trigger = EventTrigger(name: "purchase", filters: [ "event.properties.item_name": ["in": ["iPhoneX", "iPad"]] ])
    
// Schedule the trigger until the event occurs
Xray.data.schedule(payload: DataPayload(data: "Thanks for your purchase".data(using: .utf8)!, trigger: .event(trigger)))
```


To facilitate dynamic creation of the filters, you can use json to create them. So given the following json

```json
{
  "AND": [
    {
      "event.properties.item_name": {
        "BEGINSWITH": "iP"
      }
    },
    {
      "event.properties.item_description": {
        "in": [
          "Apple",
          "Google"
        ]
      }
    },
    {
      "OR": [
        {
          "event.properties.item_sale": {
            "==": true
          }
        },
        {
          "event.properties.item_inventory_count": {
            ">=": 11
          }
        }
      ]
    }
  ]
}
```

you can create a DataTrigger

```swift
let jsonFiltersData: Data = ...
EventTrigger(name: "purchase", jsonFilters: data)

Xray.data.schedule(payload: DataPayload(data: "Thanks for your purchase".data(using: .utf8)!, trigger: .event(trigger)))
```

You can find more filter examples in the [Example](Example/FilterExamples) directory



### Contribute & Development

See [CONTRIBUTING.md](CONTRIBUTING.md)

 

[badge-languages]: https://img.shields.io/badge/languages-Swift-orange.svg
[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage-green.svg
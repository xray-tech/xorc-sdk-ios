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
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eventButtonAction(sender: Any) {
        Xray.events.log(event: Event(name: "my_event"))
    }
}

//
//  ViewController.swift
//  CryptoIOS
//
//  Created by Deepak Badiger on 12/19/18.
//  Copyright © 2018 Deepak Badiger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        Utility.callOpenSSLMethods()
        Utility.callElipticalCurve()
    }


}


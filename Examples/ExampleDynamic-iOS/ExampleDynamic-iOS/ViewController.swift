//
//  ViewController.swift
//  ExampleDynamic-iOS
//
//  Created by Josip Cavar on 15/07/16.
//  Copyright © 2016 krzyzanowskim. All rights reserved.
//

import UIKit
import openssl

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let input = "asdf"
        MD5(input, input.characters.count, nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


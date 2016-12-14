//
//  ViewController.swift
//  BoxFitTrainingApp
//
//  Created by Jacob Adkins on 12/14/16.
//  Copyright © 2016 Jacob Adkins. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var motionHandler = MotionHandler(i: 0.02)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionHandler.start()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Jab(_ sender: UIButton) {
        print("Training Jab. . .")
        if let data = motionHandler.getNextMotion(timeout: 2.0) {
            Alamofire.request("http://website.com", method: .post, parameters: data, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                debugPrint(response)
            }
        } else {
            print("Timeout!")
        }
    }
    
    @IBAction func Uppercut(_ sender: UIButton) {
        print("Training Uppercut. . .")
        if let data = motionHandler.getNextMotion(timeout: 2.0) {
            Alamofire.request("http://website.com", method: .post, parameters: data, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                debugPrint(response)
            }
        } else {
            print("Timeout!")
        }
    }
    
    @IBAction func Hook(_ sender: UIButton) {
        print("Training Hook. . .")
        if let data = motionHandler.getNextMotion(timeout: 2.0) {
            Alamofire.request("http://website.com", method: .post, parameters: data, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                debugPrint(response)
            }
        } else {
            print("Timeout!")
        }
    }
    
    @IBAction func Block(_ sender: UIButton) {
        print("Training Block. . .")
        if let data = motionHandler.getNextMotion(timeout: 2.0) {
            Alamofire.request("http://website.com", method: .post, parameters: data, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                debugPrint(response)
            }
        } else {
            print("Timeout!")
        }
    }

}


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
    
    @IBOutlet weak var detectLabl: UILabel!
    var motionHandler = MotionHandler(i: 0.02)
    let serverUrl = "http://10.8.120.126:8000/AddDataPoint"

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
            let params: [String:Any] = [
                "feature" : data,
                "label" : "jab",
                "dsid" : 0
            ]
            Alamofire.request(serverUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
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
            let params: [String:Any] = [
                "feature" : data,
                "label" : "uppercut",
                "dsid" : 0
            ]
            Alamofire.request(serverUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
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
            let params: [String:Any] = [
                "feature" : data,
                "label" : "hook",
                "dsid" : 0
            ]
            Alamofire.request(serverUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
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
            let params: [String:Any] = [
                "feature" : data,
                "label" : "block",
                "dsid" : 0
            ]
            Alamofire.request(serverUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                debugPrint(response)
            }
        } else {
            print("Timeout!")
        }
    }
    
    @IBAction func Detect(_ sender: UIButton) {
        print("predicting move")
        if let data = motionHandler.getNextMotion(timeout: 2.0) {
            let params: [String:Any] = [
                "feature" : data,
                "dsid" : 0
            ]
            Alamofire.request("http://10.8.120.126:8000/PredictOne", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                debugPrint(response)
            }
        } else {
            print("Timeout!")
        }
    }
    
    

}


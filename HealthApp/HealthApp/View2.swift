//
//  View2ControllerViewController.swift
//  ConUhack
//
//
//

import UIKit
import CoreMotion


class View2: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    let motionManager = CMMotionManager()
    
    let timeInterval: TimeInterval = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        startGyroUpdates()
    }
    
    func startGyroUpdates() {
        
        guard motionManager.isGyroAvailable else {
            self.textView.text = "\nThere is no rotation sensor\n"
            return
        }
        
        
        self.motionManager.gyroUpdateInterval = self.timeInterval
        
        var max:Double = 0
        
        let queue = OperationQueue.current
        self.motionManager.startGyroUpdates(to: queue!, withHandler: { (gyroData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            var g:Double
            if self.motionManager.isGyroActive {
                if let rotationRate = gyroData?.rotationRate {
                    g = pow(rotationRate.x.self,2) + pow(rotationRate.y.self,2) + pow(rotationRate.z.self,2)
                    g = g.squareRoot()
                    if g > max {
                        max = g
                    }
                    
                    var text = "---Current totation data(falling down parameter)---\n"
                    text += "x: \(rotationRate.x)\n"
                    text += "y: \(rotationRate.y)\n"
                    text += "z: \(rotationRate.z)\n"
                    text += "Accerator: \(g)\n "
                    text += "Max: \(max)\n "
                    self.textView.text = text
                    
                    if g > 7 && g < 15{
                        text += "enter alert"
                    }
                }
            }
        })
    }
    
    
    //    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
    //        let Process= init()
    //        let pipe = Pipe()
    //
    //        task.launchPath = "/usr/bin/arch"
    //        task.arguments = ["-x86_64", "/usr/bin/python", "/Users/tomas/Developement/N_news_reader/NReader1/ahoj.py"]
    //
    //        task.standardOutput = pipe
    //
    //        task.launch()
    //
    //        let data = pipe.fileHandleForReading.readDataToEndOfFile()
    //        var news: String = (NSString(data: data, encoding: NSUTF8StringEncoding) as? String)!
    //
    //        self.widgetLabel.stringValue = news
    //
    //        completionHandler(.NewData)
    //    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



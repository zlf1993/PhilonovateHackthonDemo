//
//  View2ControllerViewController.swift
//  ConUhack
//
//  Created by 李雪颖 on 2018-01-27.
//  Copyright © 2018 Li arthur. All rights reserved.
//

import UIKit
import CoreMotion
    
class View2ControllerViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    let motionManager = CMMotionManager()
    
        let timeInterval: TimeInterval = 0.2
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
     
            startGyroUpdates()
        }

        func startGyroUpdates() {
   
            guard motionManager.isGyroAvailable else {
                self.textView.text = "\n当前设备不支持陀螺仪\n"
                return
            }
            
     
            self.motionManager.gyroUpdateInterval = self.timeInterval
            
       
            let queue = OperationQueue.current
            self.motionManager.startGyroUpdates(to: queue!, withHandler: { (gyroData, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
      
                if self.motionManager.isGyroActive {
                    if let rotationRate = gyroData?.rotationRate {
                        var text = "---当前陀螺仪数据---\n"
                        text += "x: \(rotationRate.x)\n"
                        text += "y: \(rotationRate.y)\n"
                        text += "z: \(rotationRate.z)\n"
                        self.textView.text = text
                    }
                }
            })
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
}

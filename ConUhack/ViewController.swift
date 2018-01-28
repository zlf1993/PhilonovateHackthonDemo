//
//  ViewController.swift
//  ConUhack
//
//  Created by Li arthur on 27/01/2018.
//  Copyright © 2018 Li arthur. All rights reserved.
//

import UIKit
import Speech
class ViewController: UIViewController, UITextFieldDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var word = "";
     let time: [String] = ["days","day","weeks","week","month","months","year","years"]
    var med: [String] = []
    var dic : [String:String] = ["time period":"" , "times":"", "medicine":""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        medTextField.delegate = self
        timeTextField.delegate = self
        freTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        microphoneButton.isEnabled = false
        
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
       

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
         let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                self.word = (result?.bestTranscription.formattedString)!
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
  
    @IBOutlet weak var medTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var freTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
            let texts: [String] = [word]
            for text in texts {

                let tokens = tokenize(sentence: text)
                
                //print("\(text) --> \(tokens)")
                for index in 0..<tokens.count{
                    if(time.contains(tokens[index])){
                        print(tokens[index-1])
                        print(tokens[index-2])
                        if(!tokens[index-2].elementsEqual("times")){
                             dic["time period"] = tokens[index-1]  + " " + tokens[index]
                        }
                        
                    }
                    if(tokens[index].elementsEqual("everyday")){
                        print("everyday")
                        dic["time period"] = "everyday"
                    }
                    if(tokens[index].elementsEqual("times")){
                        print(tokens[index-1])
                        dic["times"] = tokens[index-1] + " " + tokens[index] + " " + tokens[index+1] + " " + tokens[index+2]
                    }
                }
            }
            POS(sentence: word)
            print(dic)
            medTextField.text = dic["medicine"]
            timeTextField.text = dic["time period"]
            freTextField.text = dic["times"]
            
        } else {
            med = []
            dic  = ["time period":"" , "times":"", "medicine":""]
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func tokenize(sentence: String) -> [String] {
        var tokens:[String] = [String]()
        
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        
        tagger.string = sentence
        let range = NSMakeRange(0, sentence.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation]
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { (tag, tokenRange, stop) in
            let word = (sentence as NSString).substring(with: tokenRange)
            tokens.append(word)
        }
        
        return tokens
    }
    
    func POS(sentence: String) {
        let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
        
        tagger.string = sentence
        let range = NSMakeRange(0, sentence.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation]
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { (tag, tokenRange, stop) in
            let word = (sentence as NSString).substring(with: tokenRange)
            if let tag = tag {
               // print("\(word) : \(tag.rawValue)")
                if(tag.rawValue.elementsEqual("Noun")){
                    //med[0] = word
                    med.append(word)
                }
            }
        }
        if (!med.isEmpty) {
            dic["medicine"] = med[0]
        }
    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        
//    }

    
}


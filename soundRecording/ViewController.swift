//
//  ViewController.swift
//  soundRecording
//
//  Created by arora_72 on 30/05/17.
//  Copyright © 2017 indresh arora. All rights reserved.
//

import UIKit
import AVFoundation

var filePath : URL!

class ViewController: UIViewController,AVAudioRecorderDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var startRecording: UIButton!
    @IBOutlet weak var recordingLbl: UILabel!
    @IBOutlet weak var stopRecording: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: properties
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var segueToSoundPlayer: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        //intial condition on loading 
        
        recordingLbl.isHidden = true
        stopRecording.isHidden = false
        startRecording.isHidden = false
    }
    
    //MARK:: ACTIONS
    func recordingUI()
    {
        //update the ui
        stopRecording.isHidden = false
        startRecording.isEnabled = false
        recordingLbl.isHidden = false

    }
    
    @IBAction func recordAudio(_ sender: UIButton)
    {
        
        //setup ausio session
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            session.requestRecordPermission(){
                [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed{
                        self.recordingUI()
                    }else{
                        print("permission denied")
                    }
                }
            }
        }catch{
            print("error in intialising the av audio session")
        }
        //create a name for the file 
        let filename = "usersVoice.wav"
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let pathArray = [dirPath, filename]
        let fileURL = URL(string: pathArray.joined(separator: "/"))

        
        do{
            //initializing and preparing the recorder
            audioRecorder = try AVAudioRecorder(url: fileURL!, settings: [String:AnyObject]())
        }catch{
            print("failed to initialize ansd preparing the recorder")
        }
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        
        audioRecorder.record()
        
    }
    
    @IBAction func stopRecording(_ sender: UIButton)
    {
        recordingLbl.isHidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance();
        do{
            try audioSession.setActive(false)
        }catch{
            //nothing significant to add
        }
        //this function stops the audio. 
    
    }
    
    //waiting to hear from audioRecorderDidFinishRecording method
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.pathExtension)
            print("audio has been recorded")
           print(recordedAudio.filePathURL)
            print(recordedAudio.title)
            filePath = recordedAudio.filePathURL
            print(filePath)
            self.performSegue(withIdentifier: "stopRecording", sender: self)
        } else {
            print("Recording was not successful")
            startRecording.isEnabled = true
            stopRecording.isHidden = true
        }
    }
    
    
    //MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundVC:playSoundsViewController = segue.destination as! playSoundsViewController
            
            let data = recordedAudio
            playSoundVC.receivedAudio = data
            // print(recordedAudio.filePathURL)
    
        
    }
}

}

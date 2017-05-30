//
//  playSoundsViewController.swift
//  soundRecording
//
//  Created by arora_72 on 30/05/17.
//  Copyright © 2017 indresh arora. All rights reserved.
//

import UIKit
import AVFoundation

class playSoundsViewController: UIViewController,AVAudioRecorderDelegate {
    
    //MARK: properties
    
    let sliderKeyValue = "Slider value key"
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    //MARK: outlets
    
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        do{
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
        }catch{
            audioPlayer = nil
//            let refreshAlert = UIAlertController(title: "fatal error ", message: "no audio has been recorded yet", preferredStyle:.alert)
//            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        )
        }
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        do{
            audioFile = try AVAudioFile(forReading: filePath as URL)
        }catch{
            audioFile = nil
        }
        setUserInterfaceToPlay(false)
    }

    func setUserInterfaceToPlay(_ input: Bool){
        startButton.isHidden = input
        stopButton.isHidden = !input
        sliderView.isEnabled = !input
    }
    
    //MARK:: actions
    
    @IBAction func playAudio(_ sender: UIButton){
        
        //get the value(volume) from the slider
        let volume = sliderView.value
        
        //playTheSound
        playAudioWithVariableVolume(volume)
        
        //setTheUI
        setUserInterfaceToPlay(true)
    }
    
    @IBAction func stopAudio(_ sender: UIButton)
    {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    @IBAction func sliderDidMove(_ sender: UISlider) {
        print("Slider vaue: \(sliderView.value)")
    }
    //MARK: play audio
    
    func playAudioWithVariableVolume(_ volume: Float){
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changeVolumeEffect = AVAudioUnitTimePitch()
        changeVolumeEffect.pitch = volume
        audioEngine.attach(changeVolumeEffect)
        
        audioEngine.connect(audioPlayerNode, to: changeVolumeEffect, format: nil)
        audioEngine.connect(changeVolumeEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil){
            // when the audio completes 
            // set the user interface on the main thread
            DispatchQueue.main.async {
                self.setUserInterfaceToPlay(false)
            }
            
        }
        do{
            try audioEngine.start()
        }catch{
            
        }
        
        audioPlayerNode.play()
    }
  }

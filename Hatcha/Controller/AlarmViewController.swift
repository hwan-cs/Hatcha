//
//  AlarmViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/06.
//

import UIKit
import Speech
import AudioKit
import AudioUnit
import CoreAudioKit
import CAudioKit
import AVFAudio
import Accelerate

class AlarmViewController: UIViewController, SFSpeechRecognizerDelegate
{
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko"))!
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart: Bool = false
    
    var audioFilePlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    var equalizer: AVAudioUnitEQ!
    var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    var audioFile: AVAudioFile!
    
    @IBOutlet var speechLabel: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "핫차"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        speechRecognizer.delegate = self
        requestPermission()
        let audioURL = Bundle.main.url(forResource: "audiotest", withExtension: "mp3")
        
//        equalizer = AVAudioUnitEQ(numberOfBands: 0)
//        audioEngine.attach(audioPlayerNode)
//        audioEngine.attach(equalizer)
//        let bands = equalizer.bands
//        //let globalGain = equalizer.globalGain
//        let freqs = [60, 230, 910, 4000, 14000]
//        audioEngine.connect(audioPlayerNode, to: equalizer, format: nil)
//        audioEngine.connect(equalizer, to: audioEngine.outputNode, format: nil)
//        equalizer.globalGain = 24
//        do {
//                audioFile = try AVAudioFile(forReading: audioURL!)
//                audioEngine.prepare()
//                try audioEngine.start()
//                audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
//                audioPlayerNode.play()
//        } catch {
//            print ("An error occured.")
//        }
        do
        {
            print("inside do")
            let audioFile = try AVAudioFile(forReading: audioURL!)
            let readBuffer = AVAudioPCMBuffer.init(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
            try audioFile.read(into: readBuffer)
//            print(self.getDecibles1(buffer: readBuffer!))
            let normalizedBuffer = readBuffer.normalize()!
            
            var mainMixer = audioEngine.mainMixerNode
            audioEngine.attach(audioFilePlayer)
            audioEngine.connect(audioFilePlayer, to: mainMixer, format: normalizedBuffer.format)
            audioEngine.inputNode.outputFormat(forBus: 0)
            audioFilePlayer.play()
            audioFilePlayer.scheduleBuffer(normalizedBuffer, completionHandler: nil)
        }
        catch let error
        {
            print(error.localizedDescription)
        }
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
        let request = SFSpeechURLRecognitionRequest(url: audioURL!)
//
//        request.shouldReportPartialResults = true
//
//        if (recognizer?.isAvailable)! {
//
//            recognizer?.recognitionTask(with: request) { result, error in
//                guard error == nil else { print("Error: \(error!)"); return }
//                guard let result = result else { print("No result!"); return }
//
//                print(result.bestTranscription.formattedString)
//            }
//        } else {
//            print("Device doesn't support speech recognition")
//        }
//        if let file = try? AVAudioFile(forReading: audioURL!) {
//            // Set the new max level (in dB) for the gain here.
//            if let normalizedFile = try? file.normalized(newMaxLevel: -4) {
//                print(normalizedFile.maxLevel)
//                // Play your normalizedFile...
//            }
//        }
       // startSpeechRecognition()
    }
    func getDecibles1(buffer: AVAudioPCMBuffer) -> Float
    {
       // This method will compute the Real Mean Squared (RMS) value of an audio
       // PCM buffer that will return the Decibile (dB) level of an audio signal.
       // RMS will be calculated for all channels with a signal and averaged
       // which then provides true dB of the audio for all channels.
       let frameLength = UInt(buffer.frameLength)
       let channels = Int(buffer.format.channelCount)
       var channelsWithSignal = Float(channels)
       var rms:Float = 0
       var rmsSumOfChannels: Float = 0
       for channel in 0..<channels {
           guard let channelData = buffer.floatChannelData?[channel] else { return 0 }
           vDSP_measqv(channelData, 1, &rms, frameLength)
           if rms > 0 {
               rmsSumOfChannels += rms
           } else {
               channelsWithSignal -= 1
           }
        }
        // If you need the average power, uncomment the line below
        //let avgPower = 20 * log10(rmsSumOfChannels/channelsWithSignal)
        let dB = 10 * log10(rmsSumOfChannels/channelsWithSignal)
        return dB
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.barStyle = .black
    }
    @IBAction func cancelAlarmTapped(_ sender: UIButton)
    {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController")
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
        {
            window.rootViewController = vc
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    //MARK: - SFSpeechRecognizer Delegate methods
    func requestPermission()
    {
        SFSpeechRecognizer.requestAuthorization
        { authState in
            OperationQueue.main.addOperation
            {
                if authState == .authorized
                {
                    print("accepted")
                }
                else if authState == .denied
                {
                    self.alertView("User denied permission")
                }
                else if authState == .notDetermined
                {
                    self.alertView("Speech recognition not available in user's device")
                }
                else if authState == .restricted
                {
                    self.alertView("Restricted from using speech recognition")
                }
            }
        }
    }
    
    func startSpeechRecognition()
    {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        request.shouldReportPartialResults = true
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
        { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do
        {
            try audioEngine.start()
        }
        catch let error
        {
            alertView("Cannot start audio engine!")
        }
        
        guard let mySpeechRecognition = SFSpeechRecognizer()
        else
        {
            self.alertView("음성인식이 허용되지 않았습니다")
            return
        }
        
        if !mySpeechRecognition.isAvailable
        {
            self.alertView("현재 음성인식 사용이 불가능합니다")
        }
        
        task = speechRecognizer.recognitionTask(with: request, resultHandler:
        { response, error in
            guard let response = response
            else
            {
                if error != nil
                {
                    self.alertView(error?.localizedDescription as! String)
                }
                else
                {
                    self.alertView("Problem in receiving response")
                }
                return
            }
            
            let message = response.bestTranscription.formattedString
            self.speechLabel.text = message
            print(message)
        })
    }
    
    func cancelSpeechRecognition()
    {
        task.finish()
        task.cancel()
        task = nil
        
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    func alertView(_ message: String)
    {
        let controller = UIAlertController.init(title: "에러 발생..!", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler:
        { _ in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }
}

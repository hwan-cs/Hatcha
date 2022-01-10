//
//  AlarmViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/06.
//

import UIKit
import Speech
import AudioKit
import CoreAudioKit
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
        
        print("????")
        speechRecognizer.delegate = self
        requestPermission()
        let audioURL = Bundle.main.url(forResource: "audiotest", withExtension: "mp3")
        
        do
        {
            let audioFile = try AVAudioFile(forReading: audioURL!)
            let readBuffer = AVAudioPCMBuffer.init(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
            try audioFile.read(into: readBuffer)
            let normalizedBuffer = readBuffer.normalize()!
            audioEngine.attach(audioFilePlayer)
            audioEngine.connect(audioFilePlayer, to: audioEngine.outputNode, format: normalizedBuffer.format)
            
            //audioEngine.inputNode.outputFormat(forBus: 0)
            
            //MARK: - Uncomment to play normalized audio
            /*
            try audioEngine.start()
            audioFilePlayer.play()
            audioFilePlayer.scheduleBuffer(normalizedBuffer, completionHandler: nil)
             */
            
            request.append(normalizedBuffer)
            //request.endAudio()
            request.shouldReportPartialResults = true

            if (speechRecognizer.isAvailable)
            {
                speechRecognizer.recognitionTask(with: request)
                { result, error in
                    guard error == nil else { print("Error: \(error!)"); return }
                    guard let result = result else { print("No result!"); return }
                    print(result.bestTranscription.formattedString)
                }
            }
            else
            {
                print("Device doesn't support speech recognition")
            }
            print("done")
        }
        catch let error
        {
            print(error.localizedDescription)
        }
       // startSpeechRecognition()
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

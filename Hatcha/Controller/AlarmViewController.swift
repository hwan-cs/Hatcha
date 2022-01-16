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
    var request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart: Bool = false
    
    var audioFilePlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    var equalizer: AVAudioUnitEQ!
    var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    var audioFile: AVAudioFile!
    
    @IBOutlet var speechLabel: UILabel!
    @IBOutlet var currentStationLabel: UILabel!
    @IBOutlet var destinationStationLabel: UILabel!
    
    let data = Array(Set(Subway.stations.map{$0.value}.flatMap{$0}))
    var destination: String?
    var lineNo: String?
    var SRResult = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "핫차"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
//        destinationStationLabel.text = "도착 역: \(destination!)"
        currentStationLabel.adjustsFontSizeToFitWidth = true
        speechRecognizer.delegate = self
        requestPermission()
        
        let audioURL = Bundle.main.url(forResource: "audiotest", withExtension: "m4a")
        do
        {
            let audioFile = try AVAudioFile(forReading: audioURL!)
            // Configure the audio session for the app.
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetoothA2DP, .mixWithOthers])

            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            //try audioSession.setPreferredSampleRate(44100.0)
            let inputNode = audioEngine.inputNode

            
            let equalizer = AVAudioUnitEQ(numberOfBands: 2)

            equalizer.bands[0].filterType = .lowPass
            equalizer.bands[0].frequency = 500
            equalizer.bands[0].bypass = false

            //MARK: - Highpass filter
            equalizer.bands[1].filterType = .highPass
            equalizer.bands[1].frequency = 70
            equalizer.bands[1].bypass = false

            audioEngine.attach(equalizer)
            audioEngine.attach(audioFilePlayer)
            audioEngine.connect(audioFilePlayer, to: equalizer, format: inputNode.outputFormat(forBus: 0))
            audioEngine.connect(equalizer, to: audioEngine.outputNode, format: inputNode.outputFormat(forBus: 0))
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
            { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                for i in 0..<Int(buffer.frameCapacity)
                {
                    buffer.floatChannelData?.pointee[i] = (buffer.floatChannelData?.pointee[i])! * 2000.0
                }
                self.audioFilePlayer.scheduleBuffer(buffer, completionHandler: nil)
            }
            audioEngine.prepare()
            try audioEngine.start()
            
            //MARK: - Uncomment to play normalized audio
//            let readBuffer = AVAudioPCMBuffer.init(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
//            try audioFile.read(into: readBuffer)
//
//            for i in 0..<Int(readBuffer.frameCapacity)
//            {
//                readBuffer.floatChannelData?.pointee[i] = (readBuffer.floatChannelData?.pointee[i])! * 100.0
//            }
            
            Timer.scheduledTimer(withTimeInterval: 15, repeats: true)
            { timer in
                self.audioFilePlayer.installTap(onBus: 0, bufferSize: 1024, format: nil)
                { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                    self.request.append(buffer)
                }
                self.startSpeechRecognition()
            }
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    func avgMagnitude(buffer: AVAudioPCMBuffer) -> Float
    {
        var total: Float = 0.0
        for i in 0..<Int(buffer.frameCapacity)
        {
            total += (buffer.floatChannelData?.pointee[i].magnitude)!
        }
        return total/Float(buffer.frameCapacity)
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
    
    func determineStation(_ transcription: String) -> String
    {
        let stationsForLineNo = Subway.stations[self.lineNo!]!
        for station in stationsForLineNo
        {
            if transcription.filter({!$0.isWhitespace}).contains(station) && SRResult.isEmpty
            {
                SRResult.append(station)
            }
        }
        if !SRResult.isEmpty
        {
            currentStationLabel.text = "이번 역: \(SRResult[0])"
            SRResult = [String]()
        }
        return " "
    }
    
    func startSpeechRecognition()
    {
        self.request.shouldReportPartialResults = true
        self.speechRecognizer.defaultTaskHint = .dictation
        if (self.speechRecognizer.isAvailable)
        {
            self.speechRecognizer.recognitionTask(with: self.request, resultHandler:
            { result, error in
                guard error == nil else { print("Error: \(error!)"); return }
                guard let result = result else { print("No result!"); return }
                self.speechLabel.text = result.bestTranscription.formattedString
                print(result.bestTranscription.formattedString)
//                self.determineStation(self.speechLabel.text!)
            })
        }
        else
        {
            print("Device doesn't support speech recognition")
        }
        print("done")
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

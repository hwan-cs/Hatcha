//
//  AlarmViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/06.
//

import UIKit
import Speech
import CoreAudioKit
import AudioKit
import AudioToolbox
import SoundAnalysis

class AlarmViewController: UIViewController, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate
{
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko"))!
    var request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart: Bool = false
    
    var audioFilePlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    var audioFile: AVAudioFile!
    
    @IBOutlet var listenButtonImageView: UIImageView!
    @IBOutlet var currentStationLabel: UILabel!
    @IBOutlet var destinationStationLabel: UILabel!
    @IBOutlet var stopAlarmButton: UIButton!
    
    var destination: String?
    var lineNo: String?
    var prevStation: String?
    var isSubway: Bool?
    var SRResult = [String]()
    
    var timer: Timer?
    var speechDetected: Bool = false
    var shouldStopRecording: Bool = false
    var didPlay: Bool = false
    var containsSpeech: Bool = false
    
    var manager = LocalNotificationManager()
    
    var stationsForLineNo: [String]?
    var indexOfDestination: Int?
    
    let resultObserver = ResultsObserver()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "핫차"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        destinationStationLabel.text = "도착 역: \(destination!)"
        destinationStationLabel.adjustsFontSizeToFitWidth = true
        currentStationLabel.adjustsFontSizeToFitWidth = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(listenButtonAction(tapGestureRecognizer:)))
        listenButtonImageView.isUserInteractionEnabled = false
        listenButtonImageView.addGestureRecognizer(tapGestureRecognizer)
        stopAlarmButton.layer.cornerRadius = 12
        
        speechRecognizer.delegate = self
        requestPermission()
        
        if isSubway == true
        {
            stationsForLineNo = Subway.stations[self.lineNo!]!
            indexOfDestination = stationsForLineNo!.firstIndex(of: self.destination!)!
        }
        else
        {
            stationsForLineNo = findStationsForBus(self.lineNo!)
            indexOfDestination = stationsForLineNo!.firstIndex(of: self.destination!)!
        }
        
//        let audioURL = Bundle.main.url(forResource: "audiotest", withExtension: "m4a")
        do
        {
            // Configure the audio session for the app.
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetoothA2DP, .mixWithOthers])

            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            //try audioSession.setPreferredSampleRate(44100.0)
            let inputNode = audioEngine.inputNode
            
            let equalizer = AVAudioUnitEQ(numberOfBands: 2)
            
            //MARK: - Lowpass filter
            equalizer.bands[0].filterType = .lowPass
            equalizer.bands[0].frequency = 800
            equalizer.bands[0].bypass = false

            //MARK: - Highpass filter
            equalizer.bands[1].filterType = .highPass
            equalizer.bands[1].frequency = 60
            equalizer.bands[1].bypass = false

            audioEngine.attach(equalizer)
            audioEngine.attach(audioFilePlayer)
            audioEngine.connect(audioEngine.inputNode, to: equalizer, format: inputNode.inputFormat(forBus: 0))
            audioEngine.connect(audioFilePlayer, to: equalizer, format: inputNode.outputFormat(forBus: 0))
            audioEngine.connect(equalizer, to: audioEngine.outputNode, format: inputNode.outputFormat(forBus: 0))

            audioEngine.prepare()
            
            let version1 = SNClassifierIdentifier.version1
            //let request = try SNClassifySoundRequest(classifierIdentifier: version1)
            let defaultConfig = MLModelConfiguration()
            let subwaySoundClassifier = try SubwaySoundClassifier(configuration: defaultConfig)
            let classifySoundRequest = try SNClassifySoundRequest(mlModel: subwaySoundClassifier.model)
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            let streamAnalyzer = SNAudioStreamAnalyzer(format: inputNode.inputFormat(forBus: 0))
            try streamAnalyzer.add(classifySoundRequest, withObserver: resultObserver)
            let analysisQueue = DispatchQueue(label: "com.example.AnalysisQueue")
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
            { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                analysisQueue.async
                {
                    streamAnalyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
                    if self.resultObserver.isAnnouncement == true
                    {
                        print("appended")
                        self.request.append(buffer.normalize()!)
                        if self.shouldStopRecording == false
                        {
                            self.audioFilePlayer.scheduleBuffer(buffer, completionHandler: nil)
                        }
                    }
                }
            }
            try audioEngine.start()
            
            //MARK: - Uncomment to play normalized audio
//            let readBuffer = AVAudioPCMBuffer.init(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
//            try audioFile.read(into: readBuffer)

            self.startSpeechRecognition()
            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true)
            { timer in
                print("Timer triggered, speechdetected:\(self.speechDetected)")
                self.changeButtonStatus()
                if self.containsSpeech == false
                {
                    self.audioFilePlayer.stop()
                }
            }
            print(self.speechDetected)
        }
        catch let error
        {
            print(error.localizedDescription)
        }
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
        let alert = UIAlertController(title: "알람을 멈추시겠습니까?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "예", style: .default)
        { (action) in
            if self.task != nil
            {
                self.task.finish()
                self.task.cancel()
                self.task = nil
            }
            self.request.endAudio()
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.timer?.invalidate()
            self.timer = nil
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController")
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
            {
                window.rootViewController = vc
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Alert dismissed")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func changeButtonStatus()
    {
        if self.speechDetected == true
        {
            if self.didPlay == false
            {
                print("Button activated")
                self.listenButtonImageView.isUserInteractionEnabled = true
                self.listenButtonImageView.tintColor = .white
                self.containsSpeech = true
            }
        }
        else
        {
            print("hello \(self.didPlay)")
            if self.didPlay == true
            {
                print("Button deactivated")
                self.containsSpeech = false
                self.didPlay = false
                self.listenButtonImageView.isUserInteractionEnabled = false
                self.listenButtonImageView.tintColor = .lightGray
                self.shouldStopRecording = false
            }
            else if self.didPlay == false
            {
                self.containsSpeech = false
                self.shouldStopRecording = true
            }
        }
        self.speechDetected = false
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
    
    func determineStation(_ transcription: String)
    {
        for station in stationsForLineNo!
        {
            if transcription.filter({!$0.isWhitespace}).contains(station) && SRResult.isEmpty
            {
                SRResult.append(station)
            }
        }
        if !SRResult.isEmpty
        {
            currentStationLabel.text = "이번 역: \(SRResult[0])"
            if SRResult[0] == destination
            {
                if task != nil
                {
                    self.task.finish()
                    self.task.cancel()
                    self.task = nil
                }
                self.request.endAudio()
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.timer?.invalidate()
                self.timer = nil
                
                let arrivalNotification = Notification(destination: self.destination!, title: "핫차 도착 알림", body: "\(self.destination!)역에 도착했습니다!")
                self.manager.notifications.append(arrivalNotification)
                self.manager.schedule()
                
                let utterance = AVSpeechUtterance(string: "\(self.destination!)역에 도착했습니다!")
                let synth = AVSpeechSynthesizer()
                synth.speak(utterance)
                
                let alert = UIAlertController(title: "\(self.destination!)역에 도착했습니다!", message: "", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now()+3.0)
                {
                    alert.dismiss(animated: true, completion: nil)
                }
                DispatchQueue.main.async
                {
                    for _ in 0..<5
                    {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        sleep(1)
                    }
                }
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController")
                if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
                {
                    window.rootViewController = vc
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            }
            else if (SRResult[0] == stationsForLineNo![indexOfDestination!-1] || SRResult[0] == stationsForLineNo![indexOfDestination!+1]) && (prevStation == "true")
            {
                DispatchQueue.main.async
                {
                    for i in 0..<3
                    {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        sleep(1)
                    }
                }
                if self.manager.notifications.isEmpty == true
                {
                    let previousStationArrivalNotification = Notification(destination: SRResult[0], title: "핫차 도착 알림", body: "\(SRResult[0])역에 도착했습니다! 다음 역에 목적지에 도착합니다.")
                    self.manager.notifications.append(previousStationArrivalNotification)
                    self.manager.schedule()
                }
            }
            SRResult = [String]()
        }
    }
    
    func findStationsForBus(_ bus: String) -> [String]
    {
        var result = [String]()
        do
        {
            let path = Bundle.main.path(forResource: "seoul_bus_stations", ofType: "txt")
            let contents = try String(contentsOfFile: path!)
            let indexOfBus = contents.index(of: bus)!
            let substr = contents[indexOfBus...]
            let start = substr.firstIndex(of: "[")!
            let end = substr.firstIndex(of: "]")!
            let busStations = substr[start...end]
            
            var flag = false
            var str = ""
            for ch in busStations
            {
                if ch == "\"" && flag == false
                {
                    flag = true
                }
                else if ch == "\"" && flag == true
                {
                    flag = false
                }
                if flag == true && (ch != "[" && ch != "]" && ch != "," && ch != " " && ch != "\"")
                {
                    str.append(ch)
                }
                else if flag == false && ch == "\""
                {
                    result.append(str)
                    str = ""
                }
            }
        }
        catch let error
        {
            print(error.localizedDescription)
        }
        return result
    }
    
    func startSpeechRecognition()
    {
        self.request.shouldReportPartialResults = true
        self.speechRecognizer.defaultTaskHint = .dictation
        if (self.speechRecognizer.isAvailable)
        {
            task = self.speechRecognizer.recognitionTask(with: self.request, resultHandler:
            { result, error in
                guard error == nil else
                {
                    print("Error: \(error!)")
                    self.speechDetected = false
                    return
                }
                guard let result = result else { return }
                print("result: \(result.bestTranscription.formattedString)")
                self.determineStation(result.bestTranscription.formattedString)
                self.speechDetected = true
                self.shouldStopRecording = false
            })
        }
        else
        {
            print("Device doesn't support speech recognition")
        }
    }
    
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask)
    {
        self.speechDetected = true
    }
    
    @objc func listenButtonAction(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.didPlay = true
        self.audioFilePlayer.play()
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

//
//  AlarmViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/06.
//

import UIKit
import Speech

class AlarmViewController: UIViewController, SFSpeechRecognizerDelegate
{
    let audioEngine = AVAudioEngine()
//    let speechRecognizer:SFSpeechRecognizer? =  SFSpeechRecognizer()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko"))
//    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart: Bool = false
    
    @IBOutlet var speechLabel: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "핫차"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        requestPermission()
        startSpeechRecognition()
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
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler:
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

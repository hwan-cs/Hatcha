//
//  SelectionViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/03.
//

import UIKit
import TransitionButton

class SelectionViewController: UIViewController
{
    @IBOutlet var subway: TransitionButton!
    @IBOutlet var bus: TransitionButton!
    
    @IBOutlet var subwayView: UIView!
    @IBOutlet var busView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        subway.cornerRadius = 50
        bus.cornerRadius = 50
        subway.backgroundColor = .black
        bus.backgroundColor = .black
        
        subway.layer.borderWidth = 1
        subway.layer.borderColor = UIColor.white.cgColor
        
        bus.layer.borderWidth = 1
        bus.layer.borderColor = UIColor.white.cgColor
    }
    @IBAction func subwayButtonAction(_ sender: TransitionButton)
    {
        UIView.animate(withDuration: 0.15)
        {
            self.busView.alpha = 0.0
        }
        completion:
        { finished in
            self.busView.removeFromSuperview()
            self.subway.startAnimation()
            let qualityOfServiceClass = DispatchQoS.QoSClass.background
            let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
            backgroundQueue.async(execute:
            {
               sleep(3) // 3: Do your networking task or background work here.
               DispatchQueue.main.async(execute:
               { () -> Void in
                   self.subway.stopAnimation(animationStyle: .expand, completion:
                   {
                       print("show next viewcontroller")
                       let storyboard = UIStoryboard(name: "Main", bundle: nil)
                       let vc = storyboard.instantiateViewController(withIdentifier: K.subwayVC)
                       vc.modalPresentationStyle = .fullScreen
                       self.present(vc, animated: false, completion: nil)
                   })
               })
            })
        }
    }
    
    @IBAction func busButtonAction(_ sender: TransitionButton)
    {
        UIView.animate(withDuration: 0.15)
        {
            self.subway.alpha = 0.0
        }
        completion:
        { finished in
            self.subway.removeFromSuperview()
            self.bus.startAnimation()
            let qualityOfServiceClass = DispatchQoS.QoSClass.background
            let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
            backgroundQueue.async(execute:
            {
               sleep(3) // 3: Do your networking task or background work here.
               DispatchQueue.main.async(execute:
               { () -> Void in
                   self.bus.stopAnimation(animationStyle: .expand, completion:
                   {
                       print("show next viewcontroller")
        //                           let secondVC = UIViewController()
        //                           self.present(secondVC, animated: true, completion: nil)
                   })
               })
            })
        }
    }
}

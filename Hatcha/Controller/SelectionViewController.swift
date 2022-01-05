//
//  SelectionViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/03.
//

import UIKit

class SelectionViewController: UIViewController
{
    @IBOutlet var subway: UIButton!
    @IBOutlet var bus: UIButton!
    
    @IBOutlet var subwayView: UIView!
    @IBOutlet var busView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        subway.layer.cornerRadius = 50
        bus.layer.cornerRadius = 50
        subway.backgroundColor = .black
        bus.backgroundColor = .black
        
        subway.layer.borderWidth = 1
        subway.layer.borderColor = UIColor.white.cgColor
        
        bus.layer.borderWidth = 1
        bus.layer.borderColor = UIColor.white.cgColor
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.barStyle = .default
    }
    @IBAction func subwayButtonAction(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.15)
        {
            self.busView.alpha = 0.0
        }
        completion:
        { finished in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: K.subwayVC)
            self.present(vc, animated: true)
            {
                self.busView.alpha = 1.0
            }
        }
    }
    
    @IBAction func busButtonAction(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.15)
        {
            self.subway.alpha = 0.0
        }
        completion:
        { finished in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: K.subwayVC)
            self.present(vc, animated: true)
            {
                self.subway.alpha = 1.0
            }
        }
    }
}

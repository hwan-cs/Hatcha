//
//  AlarmViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/06.
//

import UIKit

class AlarmViewController: UIViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "핫차"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
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
}

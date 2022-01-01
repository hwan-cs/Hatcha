//
//  ViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2021/12/31.
//

import UIKit

class MainViewController: UIViewController
{
    @IBOutlet var makeAlarmButton: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
          return .lightContent
    }
}


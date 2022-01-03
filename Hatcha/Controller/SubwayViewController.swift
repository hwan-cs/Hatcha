//
//  SubwayViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/03.
//

import UIKit

class SubwayViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let backgroundFrame = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        backgroundFrame.backgroundColor = .white
        view.addSubview(backgroundFrame)
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 60, width: view.frame.size.width, height: 44))
        navBar.isTranslucent = false
        navBar.barTintColor = .white
        view.addSubview(navBar)
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        navItem.rightBarButtonItem = doneItem

        navBar.setItems([navItem], animated: false)
    }
}

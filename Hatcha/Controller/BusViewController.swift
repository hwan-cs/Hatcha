//
//  BusViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/31.
//

import UIKit
import DropDown
import RealmSwift

class BusViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var selectLineView: UIView!
    @IBOutlet var selectLineButton: UIButton!
    @IBOutlet var previousStationAlarmView: UIView!
    
    var dropDown = DropDown()
    let data = Bus.stations
    var filteredData: [String] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("viewdidload")
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        navBar.isTranslucent = false
        navBar.barTintColor = .white
        view.addSubview(navBar)
        let navItem = UINavigationItem(title: "")
        let cancelItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onCancelTap(_:)))
        let saveItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(onSaveTap(_:)))
        navItem.rightBarButtonItem = saveItem
        navItem.leftBarButtonItem = cancelItem
        navBar.setItems([navItem], animated: false)
        
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = .white
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        
        filteredData = data
        dropDown.anchorView = searchBar
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!-12)
        dropDown.backgroundColor = .white
        dropDown.selectedTextColor = .white
        dropDown.selectionBackgroundColor = UIColor.lightGray
        dropDown.direction = .bottom
        dropDown.cornerRadius = 10
        dropDown.cellNib = UINib(nibName: K.bussCellNibName, bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? BusDropDownCell else { return }
            cell.titleLabel.text = "zzz"
         }
        dropDown.show()

        
        selectLineButton.layer.cornerRadius = 10
        selectLineButton.isUserInteractionEnabled = false
        
        previousStationAlarmView.layer.cornerRadius = 16
    }
    
    @objc func onCancelTap(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onSaveTap(_ sender: UIBarButtonItem)
    {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        filteredData = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
            dat.range(of: searchText, options: .caseInsensitive) != nil
        })
        dropDown.dataSource = filteredData
        dropDown.show()
    }
}

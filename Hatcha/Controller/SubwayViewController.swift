//
//  SubwayViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/03.
//

import UIKit
import DropDown

class SubwayViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet var searchBar: UISearchBar!
    
    var dropDown = DropDown()
    let data = Array(Set(Subway.stations.map{$0.value}.flatMap{$0}))
    var filteredData: [String] = []
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
        let cancelItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onCancelTap(_:)))
        let saveItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
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
        dropDown.selectedTextColor = .blue
        dropDown.selectionBackgroundColor = UIColor.lightGray
        dropDown.direction = .bottom
        dropDown.cornerRadius = 10
        dropDown.selectionAction =
        { [unowned self] (index: Int, item: String) in
            searchBar.text = item
            searchBar.endEditing(true)
        }
    }
    
    @objc func onCancelTap(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.searchBar.endEditing(true)
    }
    
    //MARK: - SearchBar delegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        filteredData = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
            dat.range(of: searchText, options: .caseInsensitive) != nil
        })
        dropDown.dataSource = filteredData
        dropDown.show()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
        for ob: UIView in ((searchBar.subviews[0] )).subviews
        {
            if let z = ob as? UIButton
            {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        filteredData = data
        dropDown.hide()
    }

}

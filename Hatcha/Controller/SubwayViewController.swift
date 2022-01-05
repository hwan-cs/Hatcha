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
    @IBOutlet var selectLineView: UIView!
    @IBOutlet var selectLineButton: UIButton!
    
    var dropDown = DropDown()
    var lineDropDown = DropDown()
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
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        dropDown.anchorView = searchBar
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!-12)
        dropDown.backgroundColor = .white
        dropDown.selectedTextColor = .white
        dropDown.selectionBackgroundColor = UIColor.lightGray
        dropDown.direction = .bottom
        dropDown.cornerRadius = 10
        
        dropDown.selectionAction =
        { [unowned self] (index: Int, item: String) in
            searchBar.text = item
            searchBar.endEditing(true)
            selectLineButton.isUserInteractionEnabled = true
            lineDropDown.dataSource = self.findKeyForValue(value: item, dictionary: Subway.stations)!
            lineDropDown.show()
        }
        
        selectLineButton.layer.cornerRadius = 10
        selectLineButton.isUserInteractionEnabled = false
        
        lineDropDown.anchorView = selectLineView
        lineDropDown.bottomOffset = CGPoint(x: 0, y:(lineDropDown.anchorView?.plainView.bounds.height)!+2)
        lineDropDown.backgroundColor = .white
        lineDropDown.selectedTextColor = .white
        lineDropDown.selectionBackgroundColor = UIColor.lightGray
        lineDropDown.direction = .bottom
        lineDropDown.cornerRadius = 10
        
        lineDropDown.selectionAction =
        { [unowned self] (index: Int, item: String) in
            selectLineButton.setTitle(item, for: .normal)
        }
    }
    
    @IBAction func selectLineButtonAction(_ sender: UIButton)
    {
        lineDropDown.show()
    }
    
    @objc func onCancelTap(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.searchBar.endEditing(true)
    }
    
    func findKeyForValue(value: String, dictionary: [String: [String]]) -> [String]?
    {
        var result = [String]()
        for (key, array) in dictionary
        {
            if (array.contains(value))
            {
                result.append(key)
            }
        }
        return result
    }
    
    //MARK: - SearchBar delegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == ""
        {
            selectLineButton.isUserInteractionEnabled = false
            selectLineButton.setTitle("출발 역을 선택하세요...", for: .normal)
        }
        filteredData = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
            dat.range(of: searchText, options: .caseInsensitive) != nil
        })
        dropDown.dataSource = filteredData
        dropDown.show()
    }
}

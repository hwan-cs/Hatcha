//
//  SubwayViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/03.
//

import UIKit
import DropDown
import RealmSwift

protocol UpdateTVDelegate: AnyObject
{
    func update()
}

class SubwayViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var selectLineView: UIView!
    @IBOutlet var selectLineButton: UIButton!
    @IBOutlet var previousStationAlarmView: UIView!
    
    var dropDown = DropDown()
    var lineDropDown = DropDown()
    let data = Array(Set(Subway.stations.map{$0.value}.flatMap{$0}))
    var filteredData: [String] = []
    
    @IBOutlet var prevStationSwitch: UISwitch!
    
    var destination:String?
    var lineNo:String?
    var prevStation:String?
    var inEditingMode: Bool = false
    
    let realm = try! Realm()
    var subwayAlarms: Results<SubwayAlarmData>?
    
    var updateTVDelegate: UpdateTVDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        subwayAlarms = realm.objects(SubwayAlarmData.self)
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
            selectLineButton.backgroundColor = .white
            selectLineButton.setTitleColor(.black, for: .normal)
            selectLineButton.setTitle("노선을 선택하세요...", for: .normal)
            lineDropDown.dataSource = self.findKeyForValue(value: item, dictionary: Subway.stations)!
            lineDropDown.show()
        }
        dropDown.show()
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
        
        previousStationAlarmView.layer.cornerRadius = 16
        
        if destination != nil && lineNo != nil && prevStation != nil
        {
            searchBar.text = destination!
            selectLineButton.setTitle(lineNo!, for: .normal)
            prevStationSwitch.isOn = (prevStation == "true")
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
    
    @objc func onSaveTap(_ sender: UIBarButtonItem)
    {
        //save alarm info in Realm database
        if selectLineButton.titleLabel?.text == "도착 역을 선택하세요..."
        {
            let alert = UIAlertController(title: "도착 역을 선택하세요!", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0)
            {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        else if selectLineButton.titleLabel?.text == "노선을 선택하세요..."
        {
            let alert = UIAlertController(title: "노선을 선택하세요!", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0)
            {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            var flag = false
            var alarm = SubwayAlarmData()
            alarm.setup(destination: self.searchBar.text!, line: (selectLineButton.titleLabel?.text)!, prevStation: prevStationSwitch.isOn==true ? "true":"false")
            if self.destination ?? "nil"  == self.searchBar.text! && self.lineNo ?? "nil" == (self.selectLineButton.titleLabel?.text)! && self.prevStation ?? "nil" == (prevStationSwitch.isOn==true ? "true":"false")
            {
                flag = true
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                for el in subwayAlarms!
                {
                    if el.compoundKey == alarm.compoundKey
                    {
                        flag = true
                        let alert = UIAlertController(title: "이미 존재하는 알람입니다!", message: "", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now()+1.0)
                        {
                            alert.dismiss(animated: true)
                            {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
                saveSubwayAlarm(alarm)
                self.updateTVDelegate?.update()
            }
            if flag == false
            {
                if self.inEditingMode == false
                {
                    self.dismiss(animated: true)
                    {
                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AlarmViewController") as! AlarmViewController
                        vc.lineNo = self.lineDropDown.selectedItem
                        vc.destination = self.dropDown.selectedItem
                        vc.prevStation = self.prevStationSwitch.isOn==true ? "true":"false"
                        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                        if let window = scene?.windows.first
                        {
                            window.rootViewController = vc
                            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                        }
                    }
                }
                else
                {
                    self.deleteSubwayAlarm()
                    self.updateTVDelegate?.update()
                    self.dismiss(animated: true)
                }
            }
        }
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

    func saveSubwayAlarm(_ alarm: SubwayAlarmData)
    {
        do
        {
            try realm.write({
                realm.add(alarm, update: .modified)
            })
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    func deleteSubwayAlarm()
    {
        let str = "\(destination!)\(lineNo!)_\(prevStation!)"
        do
        {
            try realm.write({
                realm.delete(realm.objects(SubwayAlarmData.self).filter("compoundKey=%@", str))
            })
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - SearchBar delegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        selectLineButton.isUserInteractionEnabled = false
        selectLineButton.backgroundColor = .lightGray
        selectLineButton.setTitleColor(.white, for: .normal)
        selectLineButton.setTitle("도착 역을 선택하세요...", for: .normal)

        filteredData = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
            dat.range(of: searchText, options: .caseInsensitive) != nil
        })
        dropDown.dataSource = filteredData
        dropDown.show()
    }
}

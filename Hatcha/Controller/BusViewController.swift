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
    var lineDropDown = DropDown()
    let data = Bus.stations
    var filteredData: [String] = []
    
    var destination:String?
    var lineNo:String?
    var prevStation:String?
    var inEditingMode: Bool = false
    
    let realm = try! Realm()
    var busAlarms: Results<BusAlarmData>?
    
    var updateTVDelegate: UpdateTVDelegate?
    
    @IBOutlet var prevStationSwitch: UISwitch!
    
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
        
        busAlarms = realm.objects(BusAlarmData.self)
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
            cell.optionLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
            cell.optionLabel.text = item
            
            //버스 번호가 2/3자리라면 노란/파란 버스이다
            if item.count <= 3
            {
                //노란 버스는 총 4개
                if item == "01A" || item == "01B" || item == "02" || item == "04"
                {
                    cell.myImageview.image = UIImage(named: "yellow_bus.png")
                }
                else
                {
                    cell.myImageview.image = UIImage(named: "blue_bus.png")
                }
            }
            else //버스 번호가 4자리라면 초록/빨간 버스이다
            {
                if item == "110A고려대" || item == "110B국민대"
                {
                    cell.myImageview.image = UIImage(named: "blue_bus.png")
                }
                else if item[item.startIndex] == "9"
                {
                    cell.myImageview.image = UIImage(named: "red_bus.png")
                }
                else
                {
                    cell.myImageview.image = UIImage(named: "green_bus.png")
                }
            }
         }
        
        dropDown.selectionAction =
        { [unowned self] (index: Int, item: String) in
            searchBar.text = item
            searchBar.endEditing(true)
            selectLineButton.isUserInteractionEnabled = true
            selectLineButton.backgroundColor = .white
            selectLineButton.setTitleColor(.black, for: .normal)
            selectLineButton.setTitle("도착역을 선택하세요...", for: .normal)
            lineDropDown.dataSource = findStationsForBus(item)
            lineDropDown.show()
        }

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
        
        selectLineButton.layer.cornerRadius = 10
        selectLineButton.isUserInteractionEnabled = false
        
        previousStationAlarmView.layer.cornerRadius = 16
        
        if destination != nil && lineNo != nil && prevStation != nil
        {
            searchBar.text = destination!
            selectLineButton.setTitle(lineNo!, for: .normal)
            prevStationSwitch.isOn = (prevStation == "true")
        }
    }
    
    func findStationsForBus(_ bus: String) -> [String]
    {
        var result = [String]()
        do
        {
            let path = Bundle.main.path(forResource: "seoul_bus_stations", ofType: "txt")
            let contents = try String(contentsOfFile: path!)
            let indexOfBus = contents.index(of: bus)!
            let substr = contents[indexOfBus...]
            let start = substr.firstIndex(of: "[")!
            let end = substr.firstIndex(of: "]")!
            let busStations = substr[start...end]
            
            var flag = false
            var str = ""
            for ch in busStations
            {
                if ch == "\"" && flag == false
                {
                    flag = true
                }
                else if ch == "\"" && flag == true
                {
                    flag = false
                }
                if flag == true && (ch != "[" && ch != "]" && ch != "," && ch != " " && ch != "\"")
                {
                    str.append(ch)
                }
                else if flag == false && ch == "\""
                {
                    result.append(str)
                    str = ""
                }
            }
        }
        catch let error
        {
            print(error.localizedDescription)
        }
        return result
    }
    
    @objc func onCancelTap(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectLineButtonAction(_ sender: UIButton)
    {
        lineDropDown.show()
    }
    
    @objc func onSaveTap(_ sender: UIBarButtonItem)
    {
//        //save alarm info in Realm database
        if selectLineButton.titleLabel?.text == "버스 노선을 선택하세요..."
        {
            let alert = UIAlertController(title: "버스 노선을 선택하세요!", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0)
            {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        else if selectLineButton.titleLabel?.text == "도착역을 선택하세요..."
        {
            let alert = UIAlertController(title: "도착역을 선택하세요!", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0)
            {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            var flag = false
            var alarm = BusAlarmData()
            alarm.setup(destination: self.searchBar.text!, line: (selectLineButton.titleLabel?.text)!, prevStation: prevStationSwitch.isOn==true ? "true":"false")
            if self.destination ?? "nil"  == self.searchBar.text! && self.lineNo ?? "nil" == (self.selectLineButton.titleLabel?.text)! && self.prevStation ?? "nil" == (prevStationSwitch.isOn==true ? "true":"false")
            {
                flag = true
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                for el in busAlarms!
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
                saveBusAlarm(alarm)
                self.updateTVDelegate?.update()
            }
            if flag == false
            {
                if self.inEditingMode == false
                {
                    self.dismiss(animated: true)
                    {
                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AlarmViewController") as! AlarmViewController
                        vc.lineNo = self.dropDown.selectedItem
                        vc.destination = self.lineDropDown.selectedItem
                        vc.prevStation = self.prevStationSwitch.isOn==true ? "true":"false"
                        vc.isSubway = false
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
                    self.deleteBusAlarm()
                    self.updateTVDelegate?.update()
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func saveBusAlarm(_ alarm: BusAlarmData)
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
    
    func deleteBusAlarm()
    {
        let str = "BUS_\(destination!)\(lineNo!)_\(prevStation!)"
        do
        {
            try realm.write({
                realm.delete(realm.objects(BusAlarmData.self).filter("compoundKey=%@", str))
            })
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        selectLineButton.isUserInteractionEnabled = false
        selectLineButton.backgroundColor = .lightGray
        selectLineButton.setTitleColor(.white, for: .normal)
        selectLineButton.setTitle("버스 노선을 선택하세요...", for: .normal)

        filteredData = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
            dat.range(of: searchText, options: .caseInsensitive) != nil
        })
        dropDown.dataSource = filteredData
        dropDown.show()
    }
}
extension String
{
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index?
    {
        range(of: string, options: options)?.lowerBound
    }
    func index(from: Int) -> Index
    {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String
    {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String
    {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String
    {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

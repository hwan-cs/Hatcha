//
//  ViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2021/12/31.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UpdateTVDelegate
{
    @IBOutlet var makeAlarmButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    static var shouldReloadTV: Bool = false
    var realm: Realm? = nil
    var subwayAlarms: Results<SubwayAlarmData>?
    var busAlarms: Results<BusAlarmData>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        realm = try! Realm()
        loadAlarms()
        
        self.navigationController?.navigationBar.topItem?.title = "핫차"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        
    }
    
    func update()
    {
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == K.subOrBusSegue
        {
            print("Segue to subOrBus")
        }
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.barStyle = .black
        tableView.reloadData()
    }
    
    func loadAlarms()
    {
        subwayAlarms = realm!.objects(SubwayAlarmData.self)
        busAlarms = realm!.objects(BusAlarmData.self)
        tableView.reloadData()
    }
    
    @objc func setAlarmTapped(sender: UIButton)
    {
        let index = sender.tag
        var lineNo = ""
        var destination = ""
        var prevStation = ""
        var str = ""
        if index >= (subwayAlarms?.count)!
        {
            lineNo = self.busAlarms![index-(subwayAlarms?.count)!].destination!
            destination = self.busAlarms![index-(subwayAlarms?.count)!].line!
            prevStation = self.busAlarms![index-(subwayAlarms?.count)!].prevStation!
            str = "\(destination)번 버스 \(lineNo)역이 도착역인 알람을 설정하겠습니까?"
        }
        else
        {
            lineNo = self.subwayAlarms![index].line!
            destination = self.subwayAlarms![index].destination!
            prevStation = self.subwayAlarms![index].prevStation!
            str = "\(lineNo) \(destination)역이 도착역인 알람을 설정하겠습니까?"
        }
        let alert = UIAlertController(title: str, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "예", style: .default)
        { (action) in
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AlarmViewController") as! AlarmViewController
            vc.lineNo = lineNo
            vc.destination = destination
            vc.prevStation = prevStation
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            if let window = scene?.windows.first
            {
                window.rootViewController = vc
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Alert dismissed")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if indexPath.section == 1
        {
            let vc = storyboard.instantiateViewController(withIdentifier: K.subwayVC) as! SubwayViewController
            vc.destination = subwayAlarms![indexPath.row].destination
            vc.lineNo = subwayAlarms![indexPath.row].line
            vc.prevStation = subwayAlarms![indexPath.row].prevStation
            vc.inEditingMode = true
            vc.updateTVDelegate = self
            self.present(vc, animated: true)
        }
        else
        {
            let vc = storyboard.instantiateViewController(withIdentifier: K.busVC) as! BusViewController
            vc.destination = busAlarms![indexPath.row].destination
            vc.lineNo = busAlarms![indexPath.row].line
            vc.prevStation = busAlarms![indexPath.row].prevStation
            vc.inEditingMode = true
            vc.updateTVDelegate = self
            self.present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0
        {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))

            let label = UILabel()
            label.backgroundColor = .clear
            label.frame = CGRect.init(x: 12, y: 5, width: headerView.frame.width-12, height: headerView.frame.height)
            
            label.attributedText = NSAttributedString(string: "나의 알람", attributes: [ .font: UIFont.systemFont(ofSize: 32, weight: .semibold), .foregroundColor: UIColor.white ])

            headerView.addSubview(label)
            
            return headerView
        }
        else if section == 1
        {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

            let label = UILabel()
            label.backgroundColor = .clear
            label.frame = CGRect.init(x: 12, y: 5, width: headerView.frame.width-12, height: headerView.frame.height)
            
            label.attributedText = NSAttributedString(string: "지하철", attributes: [ .font: UIFont.systemFont(ofSize: 24, weight: .semibold), .foregroundColor: UIColor.white ])

            headerView.addSubview(label)
            
            return headerView
        }
        else if section == 2
        {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

            let label = UILabel()
            label.backgroundColor = .clear
            label.frame = CGRect.init(x: 12, y: 5, width: headerView.frame.width-12, height: headerView.frame.height)
            
            label.attributedText = NSAttributedString(string: "버스", attributes: [ .font: UIFont.systemFont(ofSize: 24, weight: .semibold), .foregroundColor: UIColor.white ])

            headerView.addSubview(label)
            
            return headerView
        }
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        return headerView
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [unowned self] action, view, completionHandler in
            do
            {
                try realm?.write({
                    realm?.delete(subwayAlarms![indexPath.row])
                })
            }
            catch let error
            {
                print(error.localizedDescription)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 1
        {
            if subwayAlarms?.count == 0
            {
                print("no cell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
                cell.textLabel?.attributedText = NSAttributedString(string: "알람 없음", attributes: [ .font: UIFont.systemFont(ofSize: 22.0, weight: .semibold), .foregroundColor: UIColor.white ])
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MyTableViewCell
            cell.setAlarmButton.tag = indexPath.row
            cell.titleLabel.attributedText = NSAttributedString(string: "\(self.subwayAlarms![indexPath.row].destination!), \(self.subwayAlarms![indexPath.row].line!)", attributes: [ .font: UIFont.systemFont(ofSize: 18.0, weight: .semibold), .foregroundColor: UIColor.white ])
            cell.setAlarmButton.addTarget(self, action: #selector(setAlarmTapped(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.section == 2
        {
            if busAlarms?.count == 0
            {
                print("no cell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
                cell.textLabel?.attributedText = NSAttributedString(string: "알람 없음", attributes: [ .font: UIFont.systemFont(ofSize: 22.0, weight: .semibold), .foregroundColor: UIColor.white ])
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MyTableViewCell
            cell.setAlarmButton.tag = indexPath.row + (subwayAlarms?.count)!
            cell.titleLabel.attributedText = NSAttributedString(string: "\(self.busAlarms![indexPath.row].destination!), \(self.busAlarms![indexPath.row].line!)", attributes: [ .font: UIFont.systemFont(ofSize: 18.0, weight: .semibold), .foregroundColor: UIColor.white ])
            cell.setAlarmButton.addTarget(self, action: #selector(setAlarmTapped(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MyTableViewCell
        return cell
    }
}


extension MainViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 0
        }
        else if section == 1
        {
            return subwayAlarms?.count == 0 ? 1:(subwayAlarms?.count as! Int)
        }
        else if section == 2
        {
            return busAlarms?.count == 0 ? 1:(busAlarms?.count as! Int)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 80
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            return "나의 알람"
        }
        else if section == 1
        {
            return "지하철"
        }
        else if section == 2
        {
            return "버스"
        }
        return ""
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
}


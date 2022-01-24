//
//  ViewController.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2021/12/31.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate
{
    @IBOutlet var makeAlarmButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var realm: Realm? = nil
    var subwayAlarms: Results<SubwayAlarmData>?
    
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
        tableView.reloadData()
    }
    
    @objc func setAlarmTapped(sender: UIButton)
    {
        let index = sender.tag
        let lineNo = self.subwayAlarms![index].line
        let destination = self.subwayAlarms![index].destination
        let alert = UIAlertController(title: "\(lineNo!) \(destination!)역이 도착역인 알람을 설정하겠습니까?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "예", style: .default)
        { (action) in
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AlarmViewController") as! AlarmViewController
            vc.lineNo = lineNo
            vc.destination = destination
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
        let vc = storyboard.instantiateViewController(withIdentifier: K.subwayVC) as! SubwayViewController
        vc.destination = subwayAlarms![indexPath.row].destination
        vc.lineNo = subwayAlarms![indexPath.row].line
        vc.prevStation = subwayAlarms![indexPath.row].prevStation
        vc.inEditingMode = true
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))

        let label = UILabel()
        label.backgroundColor = .clear
        label.frame = CGRect.init(x: 12, y: 5, width: headerView.frame.width-12, height: headerView.frame.height)
        
        label.attributedText = NSAttributedString(string: "나의 알람", attributes: [ .font: UIFont.systemFont(ofSize: 32, weight: .semibold), .foregroundColor: UIColor.white ])

        headerView.addSubview(label)
        
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
        return cell
    }
}


extension MainViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return subwayAlarms?.count == 0 ? 1:(subwayAlarms?.count as! Int)
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
        return "나의 알람"
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
}


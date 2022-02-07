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
    
    let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    let infoImageView = UIImageView(frame: CGRect(x: 80, y: 80, width: 240, height: 360))
    let pageControl = UIPageControl(frame: CGRect(x: 70, y: 440, width: 270, height: 40))
    let infoPageImg = [UIImage(named: "info1.png")!, UIImage(named: "info2.png")!, UIImage(named: "info3.png")!]
    let infoPageTitle = ["스와이프를 하여 알람을 삭제할 수 있습니다", "알람 사용 중 핸드폰을 가방에 넣지 말아주세요!", "음성이 인식되면 안내방송으로 간주하고 버튼이 켜집니다!"]
    
    let animationDuration: TimeInterval = 0.25
    let switchingInterval: TimeInterval = 3
    var transition = CATransition()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        let rightButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showInfoGallery))
        rightButtonItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightButtonItem
        self.navigationController?.view.backgroundColor = .clear
        
        infoImageView.isUserInteractionEnabled = true
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        self.infoImageView.addGestureRecognizer(swipeLeft)
        self.infoImageView.addGestureRecognizer(swipeRight)
        
        let action = UIAlertAction(title: "확인", style: .default)
        { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        showAlert.addAction(action)
    }
    
    func update()
    {
        print("update")
        loadAlarms()
        print("after loadalarms")
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
        subwayAlarms = realm!.objects(SubwayAlarmData.self)
        busAlarms = realm!.objects(BusAlarmData.self)
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
        var isSubway = true
        var str = ""
        if index >= (subwayAlarms?.count)!
        {
            lineNo = self.busAlarms![index-(subwayAlarms?.count)!].destination!
            destination = self.busAlarms![index-(subwayAlarms?.count)!].line!
            prevStation = self.busAlarms![index-(subwayAlarms?.count)!].prevStation!
            isSubway = false
            str = "\(lineNo)번 버스 \(destination)역이 도착역인 알람을 설정하겠습니까?"
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
            vc.isSubway = isSubway
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
        if indexPath.section == 1
        {
            if subwayAlarms?.count == 0
            {
                return nil
            }
        }
        else if indexPath.section == 2
        {
            if busAlarms?.count == 0
            {
                return nil
            }
        }
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [unowned self] action, view, completionHandler in
            do
            {
                try realm?.write({
                    if indexPath.section == 1
                    {
                        realm?.delete(subwayAlarms![indexPath.row])
                        tableView.reloadSections([1], with: .fade)
                    }
                    else if indexPath.section == 2
                    {
                        realm?.delete(busAlarms![indexPath.row])
                        tableView.reloadSections([2], with: .fade)
                    }
                })
            }
            catch let error
            {
                print(error.localizedDescription)
            }
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
                cell.selectionStyle = .none
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MyTableViewCell
            cell.setAlarmButton.tag = indexPath.row
            var fgColor = UIColor.white
            if self.subwayAlarms![indexPath.row].prevStation == "true"
            {
                fgColor = UIColor.systemGreen
            }
            cell.titleLabel.attributedText = NSAttributedString(string: "\(self.subwayAlarms![indexPath.row].destination!), \(self.subwayAlarms![indexPath.row].line!)", attributes: [ .font: UIFont.systemFont(ofSize: 18.0, weight: .semibold), .foregroundColor: fgColor ])
            cell.setAlarmButton.addTarget(self, action: #selector(setAlarmTapped(sender:)), for: .touchUpInside)
            cell.titleLabel.adjustsFontSizeToFitWidth = true
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
                cell.selectionStyle = .none
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MyTableViewCell
            cell.setAlarmButton.tag = indexPath.row + (subwayAlarms?.count)!
            var fgColor = UIColor.white
            if self.busAlarms![indexPath.row].prevStation == "true"
            {
                fgColor = UIColor.systemBlue
            }
            cell.titleLabel.attributedText = NSAttributedString(string: "\(self.busAlarms![indexPath.row].destination!), \(self.busAlarms![indexPath.row].line!)", attributes: [ .font: UIFont.systemFont(ofSize: 18.0, weight: .semibold), .foregroundColor: fgColor ])
            cell.titleLabel.adjustsFontSizeToFitWidth = true
            cell.setAlarmButton.addTarget(self, action: #selector(setAlarmTapped(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MyTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        if indexPath.section == 1
        {
            if subwayAlarms?.count == 0
            {
                return nil
            }
        }
        else if indexPath.section == 2
        {
            if busAlarms?.count == 0
            {
                return nil
            }
        }
        return indexPath
    }
    
    @objc func showInfoGallery()
    {
        showAlert.title = "스와이프를 하여 알람을 삭제할 수 있습니다"
        let alertHeight = NSLayoutConstraint(item: showAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 520)
        let alertWidth = NSLayoutConstraint(item: showAlert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
        showAlert.view.addConstraint(alertHeight)
        showAlert.view.addConstraint(alertWidth)
        infoImageView.image = UIImage(named: "info1.png")
        showAlert.view.addSubview(infoImageView)
    
        pageControl.numberOfPages = 3
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.8)
        
        showAlert.view.addSubview(pageControl)
        self.present(showAlert, animated: true, completion: nil)
    }
    
    @objc func getSwipeAction( _ recognizer : UISwipeGestureRecognizer)
    {
        if recognizer.direction == .right
        {
            pageControl.currentPage -= 1
        }
        else if recognizer.direction == .left
        {
            pageControl.currentPage += 1
        }
        animateImageView()
        infoImageView.image = infoPageImg[pageControl.currentPage]
        showAlert.title = infoPageTitle[pageControl.currentPage]
    }
    
    func animateImageView()
    {
        CATransaction.begin() //Begin the CATransaction

        CATransaction.setAnimationDuration(animationDuration)

        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight

        infoImageView.layer.add(transition, forKey: kCATransition)
        CATransaction.commit()
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


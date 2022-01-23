//
//  AppDelegate.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2021/12/31.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        //Realm Migration
        let config = Realm.Configuration (
            
            // 새로운 스키마 버전을 셋팅한다. 이 값은 이전에 사용했던 버전보다 반드시 커야 된다.
            schemaVersion: 1,

            // 셋팅한 스키마 버전보다 낮을때 자동으로 호출되는 코드 블럭을 셋팅한다.
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    migration.enumerateObjects(ofType: SubwayAlarmData.className()) { oldObject, newObject in
                        newObject!["compoundKey"] = String()
                    }
                }
            }
        )
                
        // 새로운 설정을 기본 저장소에 적용
        Realm.Configuration.defaultConfiguration = config
        return true
    }

}


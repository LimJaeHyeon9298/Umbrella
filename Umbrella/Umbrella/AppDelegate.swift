//
//  AppDelegate.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//

import UIKit
import HubKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self // <- 추가
        // apiKey는 앱에 넣어도 되는 공개 키다. registersDevice는 기본값(꺼짐)으로 둔다.
        Hub.configure(HubConfiguration(
            appId: "umbrella",
            baseURL: URL(string: "https://fxhnbyunwfusaeskilnh.supabase.co")!,
            apiKey: "sb_publishable_mEPChJ7YzXIt39vfq_-Jtg_QGkP_df1"
        ))
        
        sleep(2) 
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
// 추가
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        // deep link처리 시 아래 url값 가지고 처리
        _ = response.notification.request.content.userInfo

        completionHandler()
    }
}

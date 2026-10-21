//
//  HubRootView.swift
//  Umbrella
//

import SwiftUI
import HubKitUI

/// 재생 화면 위에 HubKit의 업데이트·공지 화면을 띄운다.
struct HubRootView: View {
    @State private var info: LaunchInfo?

    var body: some View {
        PlayerView()
            .hubPresentation(info)
            .task { await load() }
            // UIKit 라이프사이클에서는 scenePhase가 갱신되지 않아 알림으로 받는다.
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task { await load() }
            }
    }

    private func load() async {
        let info = await Hub.shared.start()
        self.info = info
        #if DEBUG
        // 호출이 실패하면 저장해 둔 응답이나 기본값이 온다. serverTime이 지금 시각이 아니면 새로 받은 값이 아니다.
        print("""
        [HubKit] serverTime: \(info.serverTime) (지금: \(Date()))
        [HubKit] update: \(info.update.status.rawValue), latest: \(info.update.latestVersion ?? "nil"), min: \(info.update.minSupportedVersion ?? "nil"), message: \(info.update.message ?? "nil")
        [HubKit] notices(\(info.notices.count)): \(info.notices.map { "\($0.priority.rawValue) \($0.title)" })
        [HubKit] config: \(info.config.values)
        """)
        #endif
    }
}

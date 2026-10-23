//
//  FocusTimer.swift
//  Umbrella
//

import Foundation
import Observation
import UserNotifications

/// 25분 집중, 5분 휴식을 반복한다. 지금 단계는 시작 시각에서 계산하므로 따로 돌아가는 타이머가 없다.
@Observable
final class FocusTimer {
    enum Phase {
        case focus, rest
    }

    static let focusDuration: TimeInterval = 25 * 60
    static let restDuration: TimeInterval = 5 * 60
    private static let notificationCount = 16

    private(set) var startDate: Date?

    /// `start`에 시작했을 때 `date` 시점의 단계와 그 단계가 끝나는 시각.
    static func phase(at date: Date, since start: Date) -> (phase: Phase, endsAt: Date) {
        let cycle = focusDuration + restDuration
        let inCycle = max(0, date.timeIntervalSince(start)).truncatingRemainder(dividingBy: cycle)
        let cycleStart = date.addingTimeInterval(-inCycle)
        if inCycle < focusDuration {
            return (.focus, cycleStart.addingTimeInterval(focusDuration))
        }
        return (.rest, cycleStart.addingTimeInterval(cycle))
    }

    func start() {
        let now = Date()
        startDate = now
        scheduleNotifications(from: now)
    }

    func stop() {
        startDate = nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: Self.notificationIDs)
    }

    private static var notificationIDs: [String] {
        (0..<notificationCount).map { "focus-\($0)" }
    }

    /// 단계가 바뀔 때마다 알림을 보낸다. 앱이 잠들어도 오도록 미리 걸어 둔다.
    private func scheduleNotifications(from start: Date) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            // shortcut: 앞으로 4시간치(16번)만 미리 건다, 더 오래 켜 두면 그 뒤로는 알림이 없다
            for n in 0..<Self.notificationCount {
                let cycles = Double(n / 2)
                let isFocusEnd = n % 2 == 0
                let offset = cycles * (Self.focusDuration + Self.restDuration)
                    + (isFocusEnd ? Self.focusDuration : Self.focusDuration + Self.restDuration)
                let content = UNMutableNotificationContent()
                content.title = isFocusEnd ? String(localized: "휴식 시간이에요") : String(localized: "다시 집중할 시간이에요")
                content.body = isFocusEnd ? String(localized: "5분 동안 쉬어 가세요.") : String(localized: "25분 동안 집중해 볼까요?")
                content.sound = .default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, start.addingTimeInterval(offset).timeIntervalSinceNow), repeats: false)
                center.add(UNNotificationRequest(identifier: "focus-\(n)", content: content, trigger: trigger))
            }
        }
    }
}

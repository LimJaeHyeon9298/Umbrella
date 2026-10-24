//
//  Analytics.swift
//  Umbrella
//

import AmplitudeSwift
import Foundation
import HubKit

/// 사용자 행동을 Amplitude로 보낸다.
/// 디버그 빌드와 키가 없는 빌드는 보내지 않고 콘솔에만 찍어, 개발 중에 누른 것이 실제 데이터에 섞이지 않게 한다.
enum Analytics {
    private static let amplitude: Amplitude? = {
        #if DEBUG
        return nil
        #else
        let info = Bundle.main.infoDictionary ?? [:]
        guard let key = info["AmplitudeAPIKey"] as? String, !key.isEmpty, !key.hasPrefix("$(") else { return nil }
        let zone: ServerZone = (info["AmplitudeServerZone"] as? String) == "EU" ? .EU : .US
        // 위치를 짐작할 수 있는 값은 보내지 않는다.
        let tracking = TrackingOptions().disableTrackIpAddress().disableTrackCity().disableTrackDMA().disableTrackCarrier()
        return Amplitude(configuration: Configuration(
            apiKey: key,
            serverZone: zone,
            trackingOptions: tracking,
            autocapture: [.sessions, .appLifecycles],
            // 대시보드에서 자동 수집을 몰래 늘리지 못하게 하고, SDK 진단 정보도 보내지 않는다.
            enableAutoCaptureRemoteConfig: false,
            enableDiagnostics: false
        ))
        #endif
    }()

    static func track(_ name: String, _ properties: [String: Any] = [:]) {
        #if DEBUG
        print("[Analytics] \(name) \(properties)")
        #endif
        amplitude?.track(eventType: name, eventProperties: properties)
    }

    /// HubKit이 내보내는 공지·업데이트 이벤트를 그대로 넘긴다.
    static func track(_ event: HubEvent) {
        track(event.name, event.properties.mapValues(\.foundationValue))
    }

    /// 재생 시간을 구간으로 묶는다. 초 단위 값을 그대로 보내지 않아 분석이 쉽고 이벤트도 늘지 않는다.
    static func listeningBucket(seconds: TimeInterval) -> String {
        switch seconds {
        case ..<60: return "under_1m"
        case ..<300: return "1_5m"
        case ..<1800: return "5_30m"
        case ..<3600: return "30_60m"
        default: return "over_60m"
        }
    }
}

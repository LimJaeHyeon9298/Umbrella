//
//  SettingsSheet.swift
//  Umbrella
//

import SwiftUI

/// 화면 켜 두기, 구매 복원, 앱 정보.
struct SettingsSheet: View {
    static let keepScreenOnKey = "petrichor.keepScreenOn"

    @Bindable var store: Store
    @AppStorage(SettingsSheet.keepScreenOnKey) private var keepScreenOn = false
    @State private var isRestoring = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("재생 중 화면 켜 두기", isOn: $keepScreenOn)
                        .onChange(of: keepScreenOn) { _, on in
                            Analytics.track("keep_screen_on_toggled", ["on": on])
                        }
                } footer: {
                    Text("집중 타이머를 켜면 이 설정과 상관없이 화면이 켜져 있어요.")
                }
                Section("구매") {
                    if store.ownsBaseCollection {
                        Label("기본 컬렉션이 열려 있어요", systemImage: "checkmark.seal")
                    }
                    Button("구매 복원") {
                        Task { await restore() }
                    }
                    .disabled(isRestoring)
                    if let restoreMessage {
                        Text(restoreMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                #if DEBUG
                Section {
                    Toggle("구매 안 한 상태로 보기", isOn: $store.debugShowsLocked)
                } header: {
                    Text("테스트")
                } footer: {
                    Text("디버그 빌드에만 보여요. 결제 기록 자체를 지우려면 Xcode의 Debug > StoreKit > Manage Transactions를 써요.")
                }
                #endif
                Section {
                    Link("개인정보처리방침", destination: URL(string: "https://www.jaehyeon.dev/apps/umbrella/privacy")!)
                    Link("문의하기", destination: URL(string: "https://www.jaehyeon.dev/apps/umbrella/support")!)
                    LabeledContent("버전", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func restore() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await store.restore()
            Analytics.track("restore_result", ["source": "settings", "result": store.ownsBaseCollection ? "restored" : "nothing"])
            restoreMessage = store.ownsBaseCollection ? String(localized: "구매를 복원했어요.") : String(localized: "복원할 구매 내역이 없어요.")
        } catch {
            Analytics.track("restore_result", ["source": "settings", "result": "failed"])
            restoreMessage = String(localized: "구매 내역을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.")
        }
    }
}

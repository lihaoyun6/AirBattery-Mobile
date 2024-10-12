//
//  AirBatteryApp.swift
//  AirBattery
//
//  Created by apple on 2024/10/8.
//

import SwiftUI

@main
struct AirBatteryApp: App {
    @AppStorage("ncGroupID") var ncGroupID = ""
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var netcastService = MultipeerService(serviceType: "airbattery-nc")
    @State private var loading = false
    
    init() {
        fetchUpdateData(from: updateURL) { result in
            switch result {
            case .success(let updateData):
                if let latestUpdate = getLatestSupportedVersion(for: updateData) {
                    if let currentAppVersion = currentAppVersion,
                       currentAppVersion.compare(latestUpdate.version, options: .numeric) == .orderedAscending {
                        print("有新版本可用：\(latestUpdate.version)，当前版本：\(currentAppVersion)")
                        // 在这里可以处理更新逻辑，例如提醒用户更新
                    } else {
                        print("当前已是最新版本")
                    }
                } else {
                    print("没有找到支持当前系统版本的更新信息")
                }
            case .failure(let error):
                print("获取更新数据失败: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(loading: $loading)
                .environmentObject(netcastService)
        }.onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("ℹ️ App actived")
                //netcastService.resume()
                loading = true
                let data = AirBatteryModel.shared.devices
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    netcastService.refeshAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if data == AirBatteryModel.shared.devices {
                            netcastService.refeshAll()
                        }
                        loading = false
                    }
                }
            } else if newPhase == .background {
                //netcastService.stop()
            }
        }
    }
}

extension String {
    var local: String { return NSLocalizedString(self, comment: "") }
}

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

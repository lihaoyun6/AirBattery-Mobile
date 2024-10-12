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
    @StateObject private var updates = Updates()
    @State private var loading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    func checkForUpdates() {
        fetchUpdateData(from: updateSource) { result in
            switch result {
            case .success(let updateData):
                if let latestUpdate = getLatestSupportedVersion(for: updateData) {
                    if let currentAppVersion = currentAppVersion,
                       currentAppVersion.compare(latestUpdate.version, options: .numeric) == .orderedAscending {
                        DispatchQueue.main.async {
                            updates.latest = latestUpdate
                            alertTitle = "Update Available".local
                            alertMessage = "v\(latestUpdate.version) " + "has been released,\nthe current version is".local + " v\(currentAppVersion)"
                            showAlert = true
                        }
                        print("ℹ️ New version available: \(latestUpdate.version), current version: \(currentAppVersion)")
                    } else {
                        print("ℹ️ You're up to date")
                    }
                } else {
                    print("ℹ️ No updates for current system version")
                }
            case .failure(let error):
                print("⚠️ Update error: \(error)")
            }
        }
    }
    
    //init() { checkForUpdates() }
    
    var body: some Scene {
        WindowGroup {
            ContentView(loading: $loading)
                .onAppear { checkForUpdates() }
                .environmentObject(netcastService)
                .environmentObject(updates)
                .alert(isPresented: $showAlert) {
                    if alertTitle == "Update Available".local {
                        Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            primaryButton: .default(Text("Download")) {
                                if let urlString = updates.latest?.url,
                                   let url = URL(string: urlString) {
                                    UIApplication.shared.open(url)
                                }
                            },
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    } else {
                        Alert(title: Text(alertTitle), message: Text(alertMessage))
                    }
                }
        }.onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("ℹ️ App actived")
                //netcastService.resume()
                loading = true
                let data = AirBatteryModel.shared.devices
                checkWiFiConnection { isConnected in
                    if isConnected {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            netcastService.refeshAll()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if data == AirBatteryModel.shared.devices {
                                    netcastService.refeshAll()
                                }
                                loading = false
                            }
                        }
                    } else {
                        loading = false
                        alertTitle = "No Wi-Fi Connection".local
                        alertMessage = "Please connect to Wi-Fi first!".local
                        showAlert = true
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

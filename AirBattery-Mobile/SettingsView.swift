//
//  SettingsView.swift
//  AirBattery
//
//  Created by apple on 2024/10/8.
//

import UIKit
import SwiftUI
import MultipeerKit

struct SettingsView: View {
    @ObservedObject var netcastService: MultipeerService
    @AppStorage("ncGroupID") var ncGroupID = ""
    @AppStorage("disappearTime") var disappearTime = 20
    
    @Binding var isPresented: Bool
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Orientation var orientation
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.accentGreen)
                Spacer()
                Button(action: {
                    isPresented = false
                }, label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.accentGreen)
                }).buttonStyle(.plain)
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            Form {
                Section(header: Text("NearCast").textCase(nil)) {
                    HStack {
                        Text("Group ID")
                        TextField("", text: $ncGroupID)
                            .disabled(true)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                        if !ncGroupID.isEmpty {
                            Button(action: {
                                ncGroupID = ""
                                AirBatteryModel.shared.devices.removeAll()
                            }, label: {
                                Text("Clear")
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }).buttonStyle(.borderless)
                        } else {
                            Button(action: {
                                if let id = UIPasteboard.general.string {
                                    if isGroudIDValid(id: id) {
                                        ncGroupID = id
                                        AirBatteryModel.shared.devices.removeAll()
                                        //AirBatteryModel.shared.devicesTmp.removeAll()
                                        netcastService.refeshAll()
                                        alertTitle = "Done".local
                                        alertMessage = "Joined the group successfully.".local
                                        showAlert = true
                                    } else {
                                        alertTitle = "Invalid ID".local
                                        alertMessage = "Please set a valid NearCast ID!".local
                                        showAlert = true
                                    }
                                }
                            }, label: {
                                Text("Paste")
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }).buttonStyle(.borderless)
                        }
                    }.alert(isPresented: $showAlert) { Alert(title: Text(alertTitle), message: Text(alertMessage)) }
                }
                Section(header: Text("Others").textCase(nil)) {
                    Picker("Remove Offline Devices", selection: $disappearTime) {
                        Text("20" + " mins".local).tag(20)
                        Text("40" + " mins".local).tag(40)
                        Text("60" + " mins".local).tag(60)
                        Text("Never").tag(92233720368547758)
                    }
                }
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Section(header:
                        HStack {
                        Spacer()
                        Text("AirBattery Mobile v\(appVersion)")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .opacity(0.5)
                        Spacer()
                    }) {}.textCase(nil)
                }
            }
        }
    }
}

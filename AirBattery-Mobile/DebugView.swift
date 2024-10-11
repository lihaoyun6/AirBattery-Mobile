//
//  SettingsView.swift
//  AirBattery
//
//  Created by apple on 2024/10/8.
//

import SwiftUI
import MultipeerKit

struct DebugView: View {
    @EnvironmentObject var netcastService: MultipeerService
    @AppStorage("lastUpdate") var lastUpdate = 0.0
    
    @State private var wifiConnected = false
    @State private var isExpanded = false
    @State private var peers = [Peer]()
    
    var body: some View {
        VStack {
            HStack {
                Text("Local ID")
                Spacer()
                Text(netcastService.transceiver.localPeerId ?? "")
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding([.top, .bottom], 8)
            .padding([.leading, .trailing], 20)
            .background(Color("WidgetBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style:.continuous))
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = netcastService.transceiver.localPeerId ?? ""
                }) {
                    Label("Copy Local ID", systemImage: "doc.on.doc")
                }
            }
            HStack {
                Text("Data Timeout")
                Spacer()
                if lastUpdate == 0.0 && AirBatteryModel.shared.devices.count < 1 {
                    Image(systemName: "infinity")
                        .foregroundColor(.secondary)
                } else {
                    Text(Date(timeIntervalSince1970: TimeInterval(lastUpdate)), style: .relative)
                        .foregroundColor(.secondary)
                }
            }
            .padding([.top, .bottom], 8)
            .padding([.leading, .trailing], 20)
            .background(Color("WidgetBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style:.continuous))
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading){
                    ForEach(peers.indices, id: \.self) { index in
                        Text("\(peers[index].name)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("\(peers[index].id)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                    }
                }
            } label: {
                HStack {
                    Text("Available Peers")
                        .foregroundColor(.primary)
                    if !wifiConnected {
                        Text("(No Wi-Fi Connection)")
                            .font(.footnote)
                            .foregroundColor(.orange)
                    }
                    Spacer()
                    Text("\(peers.count)")
                        .foregroundColor(.secondary)
                }
            }
            .padding([.top, .bottom], 4)
            .padding([.leading, .trailing], 20)
            .background(Color("WidgetBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style:.continuous))
        }
        .onAppear {
            checkWiFiConnection { isConnected in
                if isConnected {
                    wifiConnected = true
                    peers = removeDuplicatesPeer(peers: netcastService.transceiver.availablePeers)
                } else {
                    wifiConnected = false
                }
            }
            
        }.onChange(of: netcastService.transceiver.availablePeers) { newPeers in peers = removeDuplicatesPeer(peers: newPeers) }
    }
}

class StdoutObserver: ObservableObject {
    @Published var output: String = ""
    private var pipe: Pipe?
    
    init() {
        startCapturing()
    }
    
    private func startCapturing() {
        pipe = Pipe()
        let pipeHandle = pipe!.fileHandleForReading
        
        // 将 stdout 重定向到 pipe
        dup2(pipe!.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        // 监听 pipe 的数据流
        pipeHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let string = String(data: data, encoding: .utf8), !string.isEmpty {
                DispatchQueue.main.async {
                    self?.output += string // 追加输出内容
                }
            }
        }
    }
    
    deinit {
        pipe?.fileHandleForReading.readabilityHandler = nil
    }
}

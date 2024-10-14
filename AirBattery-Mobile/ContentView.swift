//
//  ContentView.swift
//  AirBattery
//
//  Created by apple on 2024/10/8.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var netcastService: MultipeerService
    @EnvironmentObject var updates: Updates
    @AppStorage("ncGroupID") var ncGroupID = ""
    @AppStorage("batteryMode") var batteryMode = "circle"
    
    @Binding var loading: Bool
    @Binding var showAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    
    @State private var showPopover = false
    @State private var showDebug = false
    @State private var currentTime = Date().timeIntervalSince1970
    
    @StateObject private var airBatteryModel = AirBatteryModel.shared
    //@StateObject private var stdoutObserver = StdoutObserver()
    
    @Orientation var orientation
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            currentTime = Date().timeIntervalSince1970
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("AirBattery")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.accentGreen)
                Spacer()
                if updates.latest != nil {
                    Button(action: {
                        if let urlString = updates.latest?.url,
                           let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }, label: {
                        Text("Update")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .frame(height: 28)
                            .padding([.leading, .trailing], 12)
                            .background(Color.myRed)
                            .foregroundColor(Color(UIColor.systemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style:.continuous))
                    })
                    .buttonStyle(.plain)
                    .padding(.trailing, 3)
                }
                if ncGroupID != "" {
                    if loading {
                        ActivityIndicator()
                    } else {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentGreen)
                            .onTapGesture {
                                checkWiFiConnection { isConnected in
                                    if isConnected {
                                        loading = true
                                        let data = airBatteryModel.devices
                                        netcastService.refeshAll()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { loading = false }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            if data == airBatteryModel.devices {
                                                netcastService.refeshAll()
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            alertTitle = "No Wi-Fi Connection".local
                                            alertMessage = "Please connect to Wi-Fi first!".local
                                            showAlert = true
                                        }
                                    }
                                }
                            }
                            .contextMenu {
                                Button(action: {
                                    loading = true
                                    netcastService.stop()
                                    netcastService.resume()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        netcastService.refeshAll()
                                        loading = false
                                    }
                                }) {
                                    Label("Force Refresh", systemImage: "arrow.2.circlepath.circle")
                                }
                            }
                            .onLongPressGesture {
                                let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedbackGenerator.prepare()
                                impactFeedbackGenerator.impactOccurred()
                                loading = true
                                netcastService.stop()
                                netcastService.resume()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    netcastService.refeshAll()
                                    loading = false
                                }
                            }
                    }
                    Button(action: {
                        showPopover = true
                    }, label: {
                        Image(systemName: "gearshape.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentGreen)
                    })
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(action: {
                            showDebug.toggle()
                        }) {
                            Label(showDebug ? "Hide Debug Info" : "Show Debug Info", systemImage: "info.circle")
                        }
                    }
                }
            }
            if showDebug { DebugView() }
            /*ZStack {
                Color.primary.colorInvert()
                TextEditor(text: $stdoutObserver.output)
                    .padding()
                    .font(.subheadline)
                    .background(Color.clear)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style:.continuous))*/
            if ncGroupID != "" {
                ScrollView(showsIndicators:false) {
                    ForEach(removeDuplicatesDevice(devices: Array(airBatteryModel.devices.values).flatMap { $0 }), id: \.self) { item in
                        HStack(spacing: 12) {
                            ZStack {
                                Image(getDeviceIcon(item))
                                    .resizable()
                                    .scaledToFit()
                                if item.isCharging != 0 && batteryMode == "bar" {
                                    Image(getDeviceIcon(item))
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(getPowerColor(item)))
                                        .opacity(0.8)
                                }
                            }.frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text(item.deviceName)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                if item.realUpdate != 0.0 {
                                    Text(String(format: "Updated %d mins ago".local, Int((currentTime - item.realUpdate) / 60)))
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text(String(format: "Updated %d mins ago".local, Int((currentTime - item.lastUpdate) / 60)))
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                /*if item.realUpdate != 0.0 {
                                 Text(Date(timeIntervalSince1970: TimeInterval(item.realUpdate)), style: .offset)
                                 .font(.system(size: 11, weight: .medium, design: .rounded))
                                 .foregroundColor(.secondary)
                                 } else {
                                 Text(Date(timeIntervalSince1970: TimeInterval(item.lastUpdate)), style: .offset)
                                 .font(.system(size: 11, weight: .medium, design: .rounded))
                                 .foregroundColor(.secondary)
                                 }*/
                            }
                            Spacer()
                            switch batteryMode {
                            case "battery":
                                BatteryView(item: item)
                            case "bar":
                                ZStack {
                                    Text(item.hasBattery ? "\(item.batteryLevel)%" : "?")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    if item.isCharging != 0 {
                                        Text(item.hasBattery ? "\(item.batteryLevel)%" : "?")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(getPowerColor(item)))
                                            .opacity(0.8)
                                    }
                                }
                            default:
                                CircleView(item: item)
                            }
                        }
                        .padding([.top, .bottom], 12)
                        .padding([.leading, .trailing], 20)
                        .background(
                            GeometryReader { geometry in
                                ZStack {
                                    Color("WidgetBackground")
                                    if batteryMode == "bar" {
                                        let width = CGFloat(max(10, Int(Double(item.batteryLevel)/100*geometry.size.width)))
                                        RoundedRectangle(cornerRadius: 16, style:.continuous)
                                            .fill(Color(getPowerColor(item)).opacity(0.2))
                                            .frame(width: width)
                                            .padding(.trailing, geometry.size.width - width)
                                    }
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style:.continuous))
                    }
                }
                /*.onChange(of: airBatteryModel.devicesTmp) { newValue in
                    if !newValue.isEmpty { airBatteryModel.devices = newValue }
                }*/
            } else {
                Spacer()
                VStack(spacing: 8) {
                    Text("Please set NearCast Group ID first!")
                        .foregroundColor(.secondary)
                    Image(systemName: "hand.point.down.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Image(systemName: "gearshape.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.accentGreen)
                        .onTapGesture { showPopover = true }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear { startTimer() }
        .sheet(isPresented: $showPopover) { SettingsView(isPresented: $showPopover).halfSheet() }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

public extension View {
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
    
    func halfSheet() -> some View {
        if #available(iOS 16, *) {
            return self.presentationDetents([.medium])
        } else {
            return self
        }
    }
}

struct ActivityIndicator: View {
    
    @State var currentDegrees = 0.0
    
    let colorGradient = LinearGradient(gradient: Gradient(colors: [
        .secondary, .secondary.opacity(0.75), .secondary.opacity(0.5), .secondary.opacity(0.2), .clear
    ]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Image(systemName: "arrow.clockwise.circle.fill")
            .font(.title)
            .foregroundColor(.accentGreen)
            .rotationEffect(Angle(degrees: currentDegrees))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.083, repeats: true) { _ in
                    withAnimation {
                        self.currentDegrees += 10
                    }
                }
            }
    }
}

/*#Preview {
    ContentView()
}*/

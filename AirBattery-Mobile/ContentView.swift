//
//  ContentView.swift
//  AirBattery
//
//  Created by apple on 2024/10/8.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var netcastService: MultipeerService
    @AppStorage("ncGroupID") var ncGroupID = ""
    
    @Binding var loading: Bool
    
    @State private var showPopover = false
    @State private var showAlert = false
    @State private var showDebug = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var lineWidth = 4.4
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
                                                //netcastService.stop()
                                                //netcastService.resume()
                                                netcastService.refeshAll()
                                            }
                                        }
                                    } else {
                                        alertTitle = "No Wi-Fi Connection".local
                                        alertMessage = "Please connect to Wi-Fi first!".local
                                        showAlert = true
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
                            .alert(isPresented: $showAlert) { Alert(title: Text(alertTitle), message: Text(alertMessage)) }
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
                            Image(getDeviceIcon(item))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text(item.deviceName)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
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
                            ZStack{
                                Group {
                                    Group {
                                        Circle()
                                            .stroke(lineWidth: lineWidth)
                                            .opacity(0.15)
                                        Circle()
                                            .trim(from: 0.0, to: CGFloat(min(Double(item.batteryLevel)/100.0, 0.5)))
                                            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                            .foregroundColor(Color(getPowerColor(item)))
                                        Circle()
                                            .trim(from: CGFloat(abs((min(Double(item.batteryLevel)/100.0, 1.0))-0.001)), to: CGFloat(abs((min(Double(item.batteryLevel)/100.0, 1.0))-0.0005)))
                                            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                            .foregroundColor(Color(getPowerColor(item)))
                                            .shadow(color: .black, radius: lineWidth*0.76, x: 0, y: 0)
                                            .clipShape( Circle().stroke(lineWidth: lineWidth) )
                                        Circle()
                                            .trim(from: item.batteryLevel > 50 ? 0.25 : 0, to: CGFloat(min(Double(item.batteryLevel)/100.0, 1.0)))
                                            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                            .foregroundColor(Color(getPowerColor(item)))
                                    }.rotationEffect(Angle(degrees: 270.0))
                                    
                                    Text(item.hasBattery ? "\(item.batteryLevel)" : "")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .offset(y: 0.5)
                                    
                                    if item.isCharging != 0 {
                                        Image("batt_bolt_mask")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 11, alignment: .center)
                                            .blendMode(.destinationOut)
                                            .offset(y:-16.5)
                                        Image("batt_bolt")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 11, alignment: .center)
                                            .foregroundColor(item.batteryLevel == 100 ? Color("my_green") : Color.primary)
                                            .offset(y:-16.5)
                                    }
                                }.frame(width: 34, height: 34, alignment: .center)
                            }.compositingGroup()
                        }
                        .padding([.top, .bottom], 12)
                        .padding([.leading, .trailing], 20)
                        .background(Color("WidgetBackground"))
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
        .sheet(isPresented: $showPopover) { SettingsView(netcastService: netcastService, isPresented: $showPopover).halfSheet() }
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

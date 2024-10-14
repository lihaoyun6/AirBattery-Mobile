//
//  BatteryView.swift
//  AirBattery
//
//  Created by apple on 2024/2/23.
//

import SwiftUI

struct CircleView: View {
    var item: Device
    @State private var lineWidth = 4.4
    
    var body: some View {
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
                
                Text(item.hasBattery ? "\(item.batteryLevel)" : "?")
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
}

struct BatteryView: View {
    var item: Device
    
    var body: some View {
        let width = round(max(4.0, min(28.7, Double(item.batteryLevel)/100*28.7)))
        HStack(spacing: 2) {
            Text(item.hasBattery ? "\(item.batteryLevel)%" : "?")
                .font(.system(size: 15, weight: .bold, design: .rounded))
            ZStack{
                ZStack(alignment: .leading) {
                    Image(systemName: "battery.0percent")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(Color(getPowerColor(item)))
                        .frame(width: width, height: 11.5, alignment: .leading)
                        .clipShape(RoundedRectangle(cornerRadius: 2.5, style: .continuous))
                        .offset(x:6.5)
                }
                if item.deviceID == "@MacInternalBattery" {
                    if item.acPowered {
                        if item.isCharging != 0 || item.isCharged {
                            PlugView()
                        } else {
                            BoltView()
                        }
                    }
                }else{
                    if item.isCharging != 0 {
                        if item.isCharging == 5 {
                            PlugView()
                        } else {
                            BoltView()
                        }
                    }
                }
            }.compositingGroup()
        }.padding(.trailing, -7)
    }
}

struct PlugView: View {
    var body: some View {
        ZStack {
            Image(systemName: "powerplug.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("black_white"))
                .blendMode(.destinationOut)
                .rotationEffect(.degrees(-90))
                .offset(x:-1.5)
            Image(systemName: "powerplug.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("black_white"))
                .blendMode(.destinationOut)
                .rotationEffect(.degrees(-90))
                .offset(x:1.5)
            Image(systemName: "powerplug.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("black_white"))
                .blendMode(.destinationOut)
                .rotationEffect(.degrees(-90))
                .offset(x:-1.5, y:-1)
            Image(systemName: "powerplug.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("black_white"))
                .blendMode(.destinationOut)
                .rotationEffect(.degrees(-90))
                .offset(x:1.5, y:-1)
            Image(systemName: "powerplug.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("black_white"))
                .blendMode(.destinationOut)
                .rotationEffect(.degrees(-90))
                .offset(x:-1.5, y:1)
            Image(systemName: "powerplug.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("black_white"))
                .blendMode(.destinationOut)
                .rotationEffect(.degrees(-90))
                .offset(x:1.5, y:1)
            Text("|")
                .font(.system(size: 19, weight: .black))
                .foregroundColor(Color("black_white"))
                .blendMode(.destinationOut)
                .offset(y:-2.5)
            Image(systemName: "powerplug.fill")
                .font(.system(size: 14))
                .rotationEffect(.degrees(-90))
                .foregroundColor(Color("black_white"))
        }.offset(x:-1.5)
    }
}

struct BoltView: View {
    var body: some View {
        ZStack {
            Image("batt_bolt_mask")
                .interpolation(.high)
                .blendMode(.destinationOut)
                .scaleEffect(1.3)
            Image(systemName: "bolt.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("black_white"))
        }.offset(x:-1.5)
    }
}

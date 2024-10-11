//
//  Device.swift
//  AirBattery
//
//  Created by apple on 2024/10/8.
//

import SwiftUI
import Foundation

struct Device: Hashable, Codable {
    var hasBattery: Bool = true
    var deviceID: String
    var deviceType: String
    var deviceName: String
    var deviceModel: String?
    var batteryLevel: Int
    var isCharging: Int
    var isCharged: Bool = false
    var isPaused: Bool = false
    var acPowered: Bool = false
    var isHidden: Bool = false
    var lowPower: Bool = false
    var parentName: String = ""
    var lastUpdate: Double
    var realUpdate: Double = 0.0
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hasBattery)
        hasher.combine(deviceID)
        hasher.combine(deviceType)
        hasher.combine(deviceName)
        hasher.combine(deviceModel)
        hasher.combine(batteryLevel)
        hasher.combine(isCharging)
        hasher.combine(isCharged)
        hasher.combine(isPaused)
        hasher.combine(acPowered)
        hasher.combine(isHidden)
        hasher.combine(lowPower)
        hasher.combine(lastUpdate)
        hasher.combine(realUpdate)
        hasher.combine(parentName)
    }
}

class AirBatteryModel: ObservableObject {
    static var shared = AirBatteryModel()
    
    @Published var lock = false
    @Published var devices = [String: [Device]]()
    //@Published var devicesTmp = [String: [Device]]()
    
    private init() {} // 单例模式，防止外部实例化
}

func getPowerColor(_ device: Device) -> String {
    if device.lowPower { return "my_yellow" }
    
    var colorName = "my_green"
    if device.batteryLevel <= 10 {
        colorName = "my_red"
    } else if device.batteryLevel <= 20 {
        colorName = "my_yellow"
    }
    return colorName
}

func removeDuplicatesDevice(devices: [Device]) -> [Device] {
    @AppStorage("disappearTime") var disappearTime = 20
    
    var seenNames = Set<String>()
    let now = Date().timeIntervalSince1970
    let filtedDevices = devices.filter { device in
        guard !seenNames.contains(device.deviceName) else {
            return false
        }
        seenNames.insert(device.deviceName)
        return true
    }
    return filtedDevices.filter({ now - $0.lastUpdate <= Double(disappearTime * 60) })
}

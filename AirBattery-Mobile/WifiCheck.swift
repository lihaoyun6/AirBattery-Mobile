//
//  WifiCheck.swift
//  AirBattery
//
//  Created by apple on 2024/10/10.
//

import Network

func checkWiFiConnection(completion: @escaping (Bool) -> Void) {
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let queue = DispatchQueue(label: "Monitor")
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            completion(true)
        } else {
            completion(false)
        }
        monitor.cancel()
    }
    monitor.start(queue: queue)
}

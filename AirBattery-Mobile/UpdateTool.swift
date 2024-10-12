//
//  UpdateTool.swift
//  AirBattery
//
//  Created by apple on 2024/10/12.
//

import UIKit

let currentSystemVersion = UIDevice.current.systemVersion
let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let updateSource = "https://raw.githubusercontent.com/lihaoyun6/AirBattery-Mobile/refs/heads/main/update.json"

struct updateData: Codable {
    let appName: String
    let updates: [updateInfo]
}

struct updateInfo: Codable {
    let version: String
    let build: String
    let minOS: String
    let url: String
    let catalog: String
}

func fetchUpdateData(from urlString: String, timeout: TimeInterval = 10.0, completion: @escaping (Result<updateData, Error>) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
        return
    }

    // 配置URLSession并设置超时
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = timeout
    sessionConfig.timeoutIntervalForResource = timeout
    let session = URLSession(configuration: sessionConfig)

    // 创建数据任务来获取数据
    let task = session.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: 2, userInfo: nil)))
            return
        }

        do {
            // 使用 JSONDecoder 解码数据
            let decoder = JSONDecoder()
            let updateInfo = try decoder.decode(updateData.self, from: data)
            completion(.success(updateInfo))
        } catch {
            completion(.failure(error))
        }
    }
    
    task.resume()
}

func getLatestSupportedVersion(for updateData: updateData) -> updateInfo? {
    let supportedUpdates = updateData.updates.filter { update in
        return update.minOS <= currentSystemVersion
    }
    
    // 按版本号排序，找到最新版本
    return supportedUpdates.sorted {
        $0.version.compare($1.version, options: .numeric) == .orderedDescending
    }.first
}

class Updates: ObservableObject {
    @Published var latest: updateInfo?
}

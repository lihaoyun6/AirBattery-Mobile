//
//  Multipeer.swift
//  AirBattery
//
//  Created by apple on 2024/6/10.
//

import UIKit
import SwiftUI
import CryptoKit
import MultipeerKit

class MultipeerService: ObservableObject {
    @AppStorage("ncGroupID") var ncGroupID = ""
    @AppStorage("lastUpdate") var lastUpdate = Date().timeIntervalSince1970
    let transceiver: MultipeerTransceiver

    init(serviceType: String) {
        let configuration = MultipeerConfiguration(
            serviceType: serviceType,
            peerName: UIDevice.current.name,
            defaults: UserDefaults.standard,
            security: .default,
            invitation: .automatic)
        transceiver = MultipeerTransceiver(configuration: configuration)
        
        // Start the transceiver
        transceiver.resume()
        
        // Handle received data
        transceiver.receive(Data.self) { data, peer in
            if self.ncGroupID == "" { return }
            guard let message = try? JSONDecoder().decode(NCMessage.self, from: data) else {
                print("⚠️ Failed to decode message!")
                return
            }
            if message.id != self.ncGroupID.prefix(15) { return }
            switch message.command {
            case "":
                print("ℹ️ Received data message from \(peer.id)")
            default:
                return
            }
            self.lastUpdate = Date().timeIntervalSince1970
            if let jsonString = decryptString(message.content, password: self.ncGroupID) {
                if let jsonData = jsonString.data(using: .utf8) {
                    guard let devices = try? JSONDecoder().decode([Device].self, from: jsonData) else {
                        print("Failed to decode message")
                        return
                    }
                    AirBatteryModel.shared.devices[message.sender] = devices
                } else {
                    print("Failed to convert JSON string to Data.")
                }
            }
        }
        
        //transceiver.peerConnected = { _ in self.refeshAll() }
        
        print("⚙️ Nearcast Group ID: \(serviceType)")
    }
    
    func resume() {
        transceiver.resume()
        print("ℹ️ Nearcast is running...")
    }
    
    func stop() {
        transceiver.stop()
        print("ℹ️ Nearcast has stopped")
    }

    func sendMessage(_ message: NCMessage) {
        guard let data = try? JSONEncoder().encode(message) else {
            print("⚠️ Failed to encode message!")
            return
        }
        for peer in removeDuplicatesPeer(peers: transceiver.availablePeers) {
            transceiver.send(data, to: [peer])
        }
    }
    
    func refeshAll() {
        checkWiFiConnection { isConnected in
            if isConnected {
                print("ℹ️ Pulling data...")
                let message = NCMessage(id: String(self.ncGroupID.prefix(15)), sender: UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.name, command: "resend", content: "")
                self.sendMessage(message)
            } else {
                print("⚠️ No Wi-Fi connection!")
            }
        }
    }
}

func removeDuplicatesPeer(peers: [Peer]) -> [Peer] {
    var seenIDs = Set<String>()
    let filteredPeers = peers.filter { peer in
        if seenIDs.contains(peer.id) {
            return false
        } else {
            seenIDs.insert(peer.id)
            return true
        }
    }
    return filteredPeers
}


func isGroudIDValid(id: String) -> Bool {
    let pre = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9\\-]+$")
    let pasd = pre.evaluate(with: id)
    return (id.count == 23 && String(id.prefix(3)) == "nc-" && pasd)
}

func substring(from string: String, start: Int, length: Int) -> String? {
    guard start >= 0, length > 0, start + length <= string.count else {
        return nil
    }

    let startIndex = string.index(string.startIndex, offsetBy: start)
    let endIndex = string.index(startIndex, offsetBy: length)
    let substring = string[startIndex..<endIndex]
    return String(substring)
}

func generateSymmetricKey(password: String) -> SymmetricKey {
    let pass = substring(from: password, start: 15, length: 8)
    let salt = String(password.prefix(15))
    let passwordData = Data(pass!.utf8)
    let saltData = salt.data(using: .utf8)!
    let derivedKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: SymmetricKey(data: passwordData), salt: saltData, info: Data(), outputByteCount: 32)
    return derivedKey
}

func decryptString(_ string: String, password: String) -> String? {
    let key = generateSymmetricKey(password: password)
    
    do {
        guard let data = Data(base64Encoded: string) else { return nil }
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8)
    } catch {
        print("⚠️ Decryption error: \(error)")
        return nil
    }
}

struct NCMessage: Codable {
    let id: String
    let sender: String
    let command: String
    let content: String
}

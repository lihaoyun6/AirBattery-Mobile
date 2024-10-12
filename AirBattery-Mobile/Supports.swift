//
//  Supports.swift
//  AirBattery
//
//  Created by apple on 2024/10/8.
//

import Foundation

func getDeviceIcon(_ d: Device) -> String {
    switch d.deviceType {
    case "blank":
        return "blank"
    case "general_bt":
        return "bluetooth.fill"
    case "MobilePhone":
        return "iphone.gen1"
    case "iPhone":
        if let model = d.deviceModel, let m = model.components(separatedBy: ",").first, let id = m.components(separatedBy: "e").last {
            if (Int(id) ?? 0 < 10) || ["iPhone12,8", "iPhone14,6"].contains(model) { return "iphone.gen1" }
            if (Int(id) ?? 0 < 14) { return "iphone.gen2" }
        }
        return "iphone"
    case "iPad":
        if let model = d.deviceModel, let m = model.components(separatedBy: ",").first, let id = m.components(separatedBy: "d").last {
            if (Int(id) ?? 0 < 13) && !["iPad8"].contains(m) { return "ipad.gen1" }
        }
        return  "ipad"
    case "iPod":
        return "ipodtouch"
    case "Watch":
        return "applewatch"
    case "RealityDevice":
        return "visionpro"
    case "Trackpad":
        return "trackpad.fill"
    case "Keyboard":
        return "keyboard.fill"
    case "MMouse":
        return "magicmouse.fill"
    case "Mouse":
        return "computermouse.fill"
    case "Gamepad":
        return "gamecontroller.fill"
    case "Headphones":
        return "headphones"
    case "Headset":
        return "headphones"
    case "ApplePencil":
        ///Model list: https://theapplewiki.com/wiki/List_of_Apple_Pencils
        if let model = d.deviceModel {
            if model == "222" { return "applepencil.gen1" }
        }
        return "applepencil.gen2"
    case "Pencil":
        return "pencil"
    case "ap_pod_right":
        if let model = d.deviceModel {
            switch model {
            case "Airpods":
                return "airpod.right"
            case "Airpods Pro":
                return "airpodpro.right"
            case "Airpods Max":
                return "airpodsmax"
            case "Airpods 2":
                return "airpod.right"
            case "Airpods 3":
                return "airpod3.right"
            case "Airpods 4":
                return "airpod4.right"
            case "Airpods Pro 2":
                return "airpodpro.right"
            case "PowerBeats 3":
                return "beats.powerbeats3.right"
            case "PowerBeats 4":
                return "beats.powerbeats4.right"
            case "PowerBeats Pro":
                return "beats.powerbeatspro.right"
            case "Beats Solo Pro":
                return "beats.headphones"
            case "Beats Studio Buds":
                return "beats.studiobud.right"
            case "Beats Flex":
                return "beats.earphones"
            case "BeatsX":
                return "beats.earphones"
            case "Beats Solo 3":
                return "beats.headphones"
            case "Beats Studio 3":
                return "beats.headphones"
            case "Beats Studio Pro":
                return "beats.headphones"
            case "Beats Fit Pro":
                return "beats.fitpro.right"
            case "Beats Studio Buds+":
                return "beats.studiobud.right"
            default:
                return "airpod.right"
            }
        }
        return "airpod.right"
    case "ap_pod_left":
        if let model = d.deviceModel {
            switch model {
            case "Airpods":
                return "airpod.left"
            case "Airpods Pro":
                return "airpodpro.left"
            case "Airpods Max":
                return "airpodsmax"
            case "Airpods 2":
                return "airpod.left"
            case "Airpods 3":
                return "airpod3.left"
            case "Airpods 4":
                return "airpod4.left"
            case "Airpods Pro 2":
                return "airpodpro.left"
            case "PowerBeats 3":
                return "beats.powerbeats3.left"
            case "PowerBeats 4":
                return "beats.powerbeats4.left"
            case "PowerBeats Pro":
                return "beats.powerbeatspro.left"
            case "Beats Solo Pro":
                return "beats.headphones"
            case "Beats Studio Buds":
                return "beats.studiobud.left"
            case "Beats Flex":
                return "beats.earphones"
            case "BeatsX":
                return "beats.earphones"
            case "Beats Solo 3":
                return "beats.headphones"
            case "Beats Studio 3":
                return "beats.headphones"
            case "Beats Studio Pro":
                return "beats.headphones"
            case "Beats Fit Pro":
                return "beats.fitpro.left"
            case "Beats Studio Buds+":
                return "beats.studiobud.left"
            default:
                return "airpod.left"
            }
        }
        return "airpod.left"
    case "ap_pod_all":
        if let model = d.deviceModel {
            switch model {
            case "Airpods":
                return "airpods"
            case "Airpods Pro":
                return "airpodspro"
            case "Airpods Max":
                return "airpodsmax"
            case "Airpods 2":
                return "airpods"
            case "Airpods 3":
                return "airpods3"
            case "Airpods 4":
                return "airpods4"
            case "Airpods Pro 2":
                return "airpodspro"
            case "PowerBeats 3":
                return "beats.powerbeats3"
            case "PowerBeats 4":
                return "beats.powerbeats4"
            case "PowerBeats Pro":
                return "beats.powerbeatspro"
            case "Beats Solo Pro":
                return "beats.headphones"
            case "Beats Studio Buds":
                return "beats.studiobud"
            case "Beats Flex":
                return "beats.earphones"
            case "BeatsX":
                return "beats.earphones"
            case "Beats Solo 3":
                return "beats.headphones"
            case "Beats Studio 3":
                return "beats.headphones"
            case "Beats Studio Pro":
                return "beats.headphones"
            case "Beats Fit Pro":
                return "beats.fitpro"
            case "Beats Studio Buds+":
                return "beats.studiobud"
            default:
                return "airpodspro"
            }
        }
        return "airpodspro"
    case "ap_case":
        if let model = d.deviceModel {
            switch model {
            case "Airpods":
                return "airpods1.case.fill"
            case "Airpods Pro":
                return "airpodspro.case.fill"
            case "Airpods Max":
                return "airpodsmax"
            case "Airpods 2":
                return "airpods.case.fill"
            case "Airpods 3":
                return "airpods3.case.fill"
            case "Airpods 4":
                return "airpods4.case.fill"
            case "Airpods Pro 2":
                return "airpodspro.case.fill"
            case "PowerBeats 3":
                return "beats.powerbeatspro.case.fill"
            case "PowerBeats 4":
                return "beats.powerbeatspro.case.fill"
            case "PowerBeats Pro":
                return "beats.powerbeatspro.case.fill"
            case "Beats Solo Pro":
                return "beats.headphones"
            case "Beats Studio Buds":
                return "beats.studiobuds.case.fill"
            case "Beats Flex":
                return "beats.earphones"
            case "BeatsX":
                return "beats.earphones"
            case "Beats Solo 3":
                return "beats.headphones"
            case "Beats Studio 3":
                return "beats.studiobuds.case.fill"
            case "Beats Studio Pro":
                return "beats.headphones"
            case "Beats Fit Pro":
                return "beats.fitpro.case.fill"
            case "Beats Studio Buds+":
                return "beats.studiobuds.case.fill"
            default:
                return "airpodspro.case.fill"
            }
        }
        return "airpodspro.case.fill"
    case "mac":
        return "display"
    case "macbook", "macbookpro", "macbookair":
        if let icon = macBookList[d.deviceModel ?? ""] { return icon }
        return "macbook"
    case "macmini":
        return "macmini.fill"
    case "macstudio":
        return "macstudio.fill"
    case "macpro":
        if let icon = macProList[d.deviceModel ?? ""] { return icon }
        return "macpro.gen3.fill"
    case "imac":
        return "desktopcomputer"
    default:
        return "questionmark.circle.fill"
    }
}

let macBookList = ["MacBookPro1,1": "macbook.gen1", "MacBookPro1,2": "macbook.gen1", "MacBookPro2,1": "macbook.gen1", "MacBookPro2,2": "macbook.gen1", "MacBookPro3,1": "macbook.gen1", "MacBookPro4,1": "macbook.gen1", "MacBookPro5,1": "macbook.gen1", "MacBookPro5,2": "macbook.gen1", "MacBookPro5,3": "macbook.gen1", "MacBookPro5,4": "macbook.gen1", "MacBookPro5,5": "macbook.gen1", "MacBookPro6,1": "macbook.gen1", "MacBookPro6,2": "macbook.gen1", "MacBookPro7,1": "macbook.gen1", "MacBookPro8,1": "macbook.gen1", "MacBookPro8,2": "macbook.gen1", "MacBookPro8,3": "macbook.gen1", "MacBookPro9,1": "macbook.gen1", "MacBookPro9,2": "macbook.gen1", "MacBookPro10,1": "macbook.gen1", "MacBookPro10,2": "macbook.gen1", "MacBookPro11,1": "macbook.gen1", "MacBookPro11,2": "macbook.gen1", "MacBookPro11,3": "macbook.gen1", "MacBookPro11,4": "macbook.gen1", "MacBookPro11,5": "macbook.gen1", "MacBookPro12,1": "macbook.gen1", "MacBookPro13,1": "macbook.gen1", "MacBookPro13,2": "macbook.gen1", "MacBookPro13,3": "macbook.gen1", "MacBookPro14,1": "macbook.gen1", "MacBookPro14,2": "macbook.gen1", "MacBookPro14,3": "macbook.gen1", "MacBookPro15,1": "macbook.gen1", "MacBookPro15,2": "macbook.gen1", "MacBookPro15,3": "macbook.gen1", "MacBookPro15,4": "macbook.gen1", "MacBookPro16,1": "macbook.gen1", "MacBookPro16,2": "macbook.gen1", "MacBookPro16,3": "macbook.gen1", "MacBookPro16,4": "macbook.gen1", "MacBookPro17,1": "macbook.gen1", "MacBookPro18,1": "macbook", "MacBookPro18,2": "macbook", "MacBookPro18,3": "macbook", "MacBookPro18,4": "macbook", "Mac14,5": "macbook", "Mac14,6": "macbook", "Mac14,7": "macbook.gen1", "Mac14,9": "macbook", "Mac14,10": "macbook", "Mac15,3": "macbook", "Mac15,6": "macbook", "Mac15,7": "macbook", "Mac15,8": "macbook", "Mac15,9": "macbook", "Mac15,10": "macbook", "Mac15,11": "macbook", "MacBookAir1,1": "macbook.gen1", "MacBookAir2,1": "macbook.gen1", "MacBookAir3,1": "macbook.gen1", "MacBookAir3,2": "macbook.gen1", "MacBookAir4,1": "macbook.gen1", "MacBookAir4,2": "macbook.gen1", "MacBookAir5,1": "macbook.gen1", "MacBookAir5,2": "macbook.gen1", "MacBookAir6,1": "macbook.gen1", "MacBookAir6,2": "macbook.gen1", "MacBookAir7,1": "macbook.gen1", "MacBookAir7,2": "macbook.gen1", "MacBookAir8,1": "macbook.gen1", "MacBookAir8,2": "macbook.gen1", "MacBookAir9,1": "macbook.gen1", "MacBookAir10,1": "macbook.gen1", "Mac14,2": "macbook", "Mac14,15": "macbook", "Mac15,12": "macbook", "Mac15,13": "macbook", "MacBook1,1": "macbook.gen1", "MacBook2,1": "macbook.gen1", "MacBook3,1": "macbook.gen1", "MacBook4,1": "macbook.gen1", "MacBook5,1": "macbook.gen1", "MacBook5,2": "macbook.gen1", "MacBook6,1": "macbook.gen1", "MacBook7,1": "macbook.gen1", "MacBook8,1": "macbook.gen1", "MacBook9,1": "macbook.gen1", "MacBook10,1": "macbook.gen1"]

let macProList = ["MacPro1,1": "macpro.gen1.fill", "MacPro2,1": "macpro.gen1.fill", "MacPro3,1": "macpro.gen1.fill", "MacPro4,1": "macpro.gen1.fill", "MacPro5,1": "macpro.gen1.fill", "MacPro6,1": "macpro.gen2.fill", "MacPro7,1": "macpro.gen3.fill", "Mac14,8": "macpro.gen3.fill"]

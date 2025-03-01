//
//  AppGroupsShared.swift
//  HTKeyboardApp
//
//  Created by xiaopin on 2024/4/10.
//

import UIKit
import Foundation

enum DataKeys:String{
    case appGroupKey = "group.com.mobiunity.dev.demo"
    case widget_kind_default = "com.mobiunity.dev.demo.widgetkind.default"
    case fileKey_currentTrack = "current_play.track"
    case udKey_IsVIP = "isVip"
    case udKey_IsPlaying = "isPlaying"
    case udKey_control_command = "control_command"
}

class AppGroupsShared{
    static func setValue(_ value:Any?, forKey key:DataKeys){
        if let userDefaults = UserDefaults(suiteName: DataKeys.appGroupKey.rawValue) {
            userDefaults.setValue(value, forKey: key.rawValue)
            userDefaults.synchronize()
        }
    }
    
    static func valueForKey(key:DataKeys) -> Any?{
        if let userDefaults = UserDefaults(suiteName: DataKeys.appGroupKey.rawValue) {
            return userDefaults.value(forKey: key.rawValue)
        }
        return nil
    }
    
    static func intForKey(key:DataKeys) -> Int{
        if let userDefaults = UserDefaults(suiteName: DataKeys.appGroupKey.rawValue) {
            return userDefaults.integer(forKey: key.rawValue)
        }
        return 0
    }
    
    static func boolForKey(key:DataKeys) -> Bool{
        if let userDefaults = UserDefaults(suiteName: DataKeys.appGroupKey.rawValue), let result = userDefaults.value(forKey: key.rawValue) as? Bool {
            return result
        }
        return false
    }

    static func stringForKey(key:DataKeys) -> String?{
        if let userDefaults = UserDefaults(suiteName: DataKeys.appGroupKey.rawValue), let str = userDefaults.string(forKey: key.rawValue) {
           return str
        }
        return nil
    }
    
    static func filePath(file fileName:DataKeys) -> String {
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return "" }
        let fileURL = file.appendingPathComponent(fileName.rawValue)
        return fileURL.absoluteString
    }
    
    static func stringForFile(file fileName:DataKeys) -> String? {
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return nil }
        let fileURL = file.appendingPathComponent(fileName.rawValue)
        guard let data = try? Data(contentsOf: fileURL), let str = String(data: data, encoding: .utf8) else { return nil}
        return str
    }
    
    static func dictionaryForFile(file fileName:DataKeys) -> [String: Any]? {
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return nil }
        let fileURL = file.appendingPathComponent(fileName.rawValue)
        guard let data = try? Data(contentsOf: fileURL), let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        return jsonObject
    }
    
    static func arrayForFile(file fileName:DataKeys) -> [Any]? {
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return nil }
        let fileURL = file.appendingPathComponent(fileName.rawValue)
        guard let data = try? Data(contentsOf: fileURL), let array = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else { return nil }
        return array
    }
    
    static func imageForFile(file fileName:String) -> UIImage? {
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return nil }
        let fileURL = file.appendingPathComponent(fileName)
        guard let image = UIImage(contentsOfFile: fileURL.path) else{return nil}
        return image
    }
    
    static func saveString(_ str:String, forFile fileName:DataKeys) -> Bool{
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return false }
        let fileURL = file.appendingPathComponent(fileName.rawValue)
        if let data = str.data(using: .utf8) {
            try? data.write(to: fileURL)
            return true
        }
        return false
    }
    
    static func saveDict(_ dict:[String:Any], forFile fileName:DataKeys) -> Bool {
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return false}
        let fileURL = file.appendingPathComponent(fileName.rawValue)
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        if let jsonData = jsonData {
            try? jsonData.write(to: fileURL)
            return true
        }
        return false
    }
    
    static func saveArray(_ array:[Any], forFile fileName:DataKeys) -> Bool{
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return false }
        let fileURL = file.appendingPathComponent(fileName.rawValue)
        let jsonData = try? JSONSerialization.data(withJSONObject: array, options: [])
        if let jsonData = jsonData {
            try? jsonData.write(to: fileURL)
            return true
        }
        return false
    }
    
    static func saveImage(_ imageData:Data?, forFile fileName:String) -> Bool {
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return false }
        let fileURL = file.appendingPathComponent(fileName)
        if let data = imageData {
            try? data.write(to: fileURL)
            return true
        }
        return false
    }
    
    static func removeFile(name fileName:String) -> Bool{
        guard let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataKeys.appGroupKey.rawValue) else { return false }
        let fileURL = file.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("File successfully removed: \(fileURL)")
            return true
        } catch {
            print("Failed to remove file: \(error)")
            return false
        }
    }
}

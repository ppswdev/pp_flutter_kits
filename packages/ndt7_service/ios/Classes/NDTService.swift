//
//  NDTService.swift
//  NDT7 iOS Example
//
//  Created by xiaopin on 2024/8/15.
//  Copyright © 2024 M-Lab. All rights reserved.
//

import Foundation
class NDTService{
    init(){
        NDT7.loggingEnabled = true
        
        let settings = NDT7Settings()
        ndt7Test = NDT7Test(settings: settings)
        ndt7Test?.delegate = self
    }
    
    //MARK: 属性
    private var ndt7Test: NDT7Test?
    
    var allServers = [[String:Any]]()
    var serversLoadedClosure:((String)->())?
    var testClosure:((String, Bool)->())?
    var measurementClosure:((String,String,String)->())?
    var errorClosure:((String,String)->())?
    
    //MARK: 方法
    func loadServers(){
        ndt7Test?.serverSetup(session: Networking.shared.session, { [weak self] error in
            OperationQueue.current?.name = "net.measurementlab.NDT7.test"
            self?.buildServersMap()
        })
    }
    
    func startTest(_ serverIndex:Int = 0){
        ndt7Test?.settings.currentServerIndex = serverIndex
        ndt7Test?.test(download: true, upload: true, error: nil, { error in
            
        })
    }
    
    func stopTest(){
        ndt7Test?.cancel()
    }
}

extension NDTService {
    func buildServersMap(){
        guard let servers = ndt7Test?.settings.allServers else{return}
        
        // 编码为 JSON 数据
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try jsonEncoder.encode(servers)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Encoded JSON: \(jsonString)")
                serversLoadedClosure?(jsonString)
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
}

extension NDTService: NDT7TestInteraction {

    func test(kind: NDT7TestConstants.Kind, running: Bool) {
        switch kind {
        case .download:
            testClosure?("download", running)
        case .upload:
            testClosure?("upload", running)
        }
    }

    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        
        // 编码为 JSON 数据
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        var jsonStr = ""
        do {
            let jsonData = try jsonEncoder.encode(measurement)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Encoded JSON2: \(jsonString)")
                jsonStr = jsonString
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
        
        
        if origin == .client {
            switch kind {
            case .download:
                measurementClosure?("client", "download", jsonStr)
            case .upload:
                measurementClosure?("client", "upload", jsonStr)
            }
        } else if origin == .server{
            switch kind {
            case .download:
                measurementClosure?("server", "download", jsonStr)
            case .upload:
                measurementClosure?("server", "upload", jsonStr)
            }
        }
    }

    func error(kind: NDT7TestConstants.Kind, error: NSError) {
        stopTest()
        switch kind {
        case .download:
            errorClosure?("download", error.localizedDescription)
        case .upload:
            errorClosure?("upload", error.localizedDescription)
        }
    }
}

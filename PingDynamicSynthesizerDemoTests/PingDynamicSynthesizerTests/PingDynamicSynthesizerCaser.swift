//
//  PingDynamicSynthesizerCaser.swift
//  ScanDepend
//
//  Created by 徐仲平 on 2019/3/27.
//  Copyright © 2019 徐仲平. All rights reserved.
//

import Foundation

class PingDynamicSynthesizerCaser {
    func caser() -> Void {
        let dir = "/Users/junghsu/Desktop/myGithub/PingDynamicSynthesizer/PingDynamicSynthesizerDemoTests/PingDynamicSynthesizerTests"
        let casehPath = dir.appending("/PingCase1.h")
        let casemPath = dir.appending("/pingCase1.m");
        
        guard FileManager.default.fileExists(atPath: casehPath) else {
            print("casehPath error")
            return
        }
        
        guard FileManager.default.fileExists(atPath: casemPath) else {
            print("casemPath error")
            return
        }
        
        let casehFileHandle = FileHandle(forReadingAtPath: casehPath)
        let casehData = casehFileHandle?.readDataToEndOfFile()
        casehFileHandle?.closeFile()
        guard casehData != nil else {
            print("casehData error")
            return
        }
        
        let casemFileHandle = FileHandle(forReadingAtPath: casemPath)
        let casemData = casemFileHandle?.readDataToEndOfFile()
        casemFileHandle?.closeFile()
        guard casemData != nil else {
            print("casemData error")
            return
        }
        
        let casehContent = String(data: casehData!, encoding: String.Encoding.utf8)!
        let casemContent = String(data: casemData!, encoding: String.Encoding.utf8)!
        
        let pattern = "PingCase1"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        for i in 2..<31 {
            let casehResult = regex?.stringByReplacingMatches(in: casehContent, options: [], range: NSMakeRange(0, casehContent.count), withTemplate: "PingCase\(i)")
            let casemResult = regex?.stringByReplacingMatches(in: casemContent, options: [], range: NSMakeRange(0, casemContent.count), withTemplate: "PingCase\(i)")
            
            
            let newCasehPath = dir.appending("/PingCase\(i).h")
            let newCasemPath = dir.appending("/PingCase\(i).m")
            
            
            FileManager.default.createFile(atPath: newCasehPath, contents: casehResult!.data(using: String.Encoding.utf8)!, attributes: nil)
            
            FileManager.default.createFile(atPath: newCasemPath, contents: casemResult!.data(using: String.Encoding.utf8)!, attributes: nil)
            
        }
        
    }
}

PingDynamicSynthesizerCaser().caser()





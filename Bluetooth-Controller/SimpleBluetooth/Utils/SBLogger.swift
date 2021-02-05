//
//  SBLogger.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/24.
//

import Foundation

public class SBLogger {
    public enum Log {
        case info(_ msg: String?)
        case error(_ errMsg: String?)
        case success(_ msg: String?)
    }
    
    public static let shared = SBLogger()
    public var logCallback: ((Log) -> Void)?
          
    func record(_ log: Log) {
        logCallback?(log)
    }
}

fileprivate func logTime() -> String {
    let dateFormatter = SBMicrosecondPrecisionDateFormatter()
    return dateFormatter.string(from: Date())
}

func logInfo(_ msg: String?) {
    SBLogger.shared.record(.info("\(logTime()) - \(msg ?? "")"))
}

func logError(_ msg: String?) {
    SBLogger.shared.record(.error("\(logTime()) - ⛔️\(msg ?? "")"))
}

func logSuccess(_ msg: String?) {
    SBLogger.shared.record(.success("\(logTime()) - ✅\(msg ?? "")"))
}

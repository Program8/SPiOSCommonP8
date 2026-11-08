//
//  FWLoggerDelegate.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 4/25/25.
//

public protocol FWLoggerDelegate {
    var tag: String { get }
    func mLog(_ funcName: String, msg: String)
    func mLogDefault(_ funcName: String, msg: String)
    func mLogInfo(_ funcName: String, msg: String)
    func mLogError(_ funcName: String, msg: String)
    func mLogDebug(_ funcName: String, msg: String)
    func mLogFault(_ funcName: String, msg: String)
}

extension FWLoggerDelegate {
    public var tag: String { "\(Self.self)" }
    
    public func mLog(_ funcName: String = #function, msg: String) {
        let tag: String = self.tag
        FWLogger.shared.default(tag: tag, message: funcName + " :: " + msg)
    }
    
    public func mLogDefault(_ funcName: String = #function, msg: String) {
        let tag: String = self.tag
        FWLogger.shared.default(tag: tag, message: funcName + " :: " + msg)
    }
    
    public func mLogInfo(_ funcName: String = #function, msg: String) {
        let tag: String = self.tag
        FWLogger.shared.info(tag: tag, message: funcName + " :: " + msg)
    }
    
    public func mLogError(_ funcName: String = #function, msg: String) {
        let tag: String = self.tag
        FWLogger.shared.error(tag: tag, message: funcName + " :: " + msg)
    }
    
    public func mLogDebug(_ funcName: String = #function, msg: String) {
        let tag: String = self.tag
        FWLogger.shared.debug(tag: tag, message: funcName + " :: " + msg)
    }
    
    public func mLogFault(_ funcName: String = #function, msg: String) {
        let tag: String = self.tag
        FWLogger.shared.fault(tag: tag, message: funcName + " :: " + msg)
    }
}

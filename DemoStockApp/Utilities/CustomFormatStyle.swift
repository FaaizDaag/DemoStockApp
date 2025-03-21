//
//  CustomFormatStyle.swift
//  DemoStockApp
//
//  Created by Faaiz Daglawala on 3/21/25.
//

import Foundation

class CustomFormatStyle: FormatStyle {
    var format: String = ""
    var isUppercase: Bool = false
    
    func format(_ value: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return isUppercase ? formatter.string(from: value).uppercased() : formatter.string(from: value).lowercased()
    }
    
    init(format: String? = nil, isUppercase: Bool = false) {
        self.format = format ?? "HH:mm:ss"
        self.isUppercase = isUppercase
    }
    
    typealias FormatInput = Date
    
    typealias FormatOutput = String
    
    var identifier: String {
        return UUID().uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: CustomFormatStyle, rhs: CustomFormatStyle) -> Bool {
        return lhs.format == rhs.format
    }
}

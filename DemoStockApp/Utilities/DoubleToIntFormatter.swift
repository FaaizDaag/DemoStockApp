//
//  DoubleToIntFormatter.swift
//  DemoStockApp
//
//  Created by Faaiz Daglawala on 3/21/25.
//

import Foundation

class DoubleToIntFormatStyle: FormatStyle {
    
    var fackeY: Double?
    
    init(fackeY: Double? = nil) {
        self.fackeY = fackeY
    }
    
    func format(_ value: Double) -> String {
        if let f = fackeY,  f == value {
            return ""
        }
        return String(Int(value.rounded()))
    }
    
    typealias FormatInput = Double
    
    typealias FormatOutput = String
    
    var identifier: String {
        return UUID().uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: DoubleToIntFormatStyle, rhs: DoubleToIntFormatStyle) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

//
//  StockListModel.swift
//  DemoStockApp
//
//  Created by Faaiz Daglawala on 3/21/25.
//

import Foundation

struct Stock: Identifiable, Decodable {
    let id = UUID()
    let symbol: String
    var price: Double?
}


/// Struct to store individual stock price points for the chart.
struct StockDataPoint: Identifiable {
    let id = UUID()         // Unique ID for SwiftUI
    let timestamp: Date     // When the price was recorded
    let price: Double       // Stock price at that time
}

//
//  StockDetailsView.swift
//  DemoStockApp
//
//  Created by Faaiz Daglawala on 3/21/25.
//

import SwiftUI
import Charts

struct StockDetailsView: View {
    let stockSymbol: String
    @ObservedObject var viewModel: StockListViewModel
    
    var body: some View {
        VStack {
            Text("Live Chart for \(stockSymbol)")
                .font(.headline)
                .padding(.top, 16)
//            Spacer()
//                .frame(height: 50)
            Chart {
                if let data = viewModel.stockPriceHistory[stockSymbol] {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("", point.timestamp, unit: .second),
                            y: .value("", point.price)
                        )
                        .interpolationMethod(.linear)
                    }
                }
            }
            .chartYAxis(content: {
                AxisMarks(position: .trailing, values: getYAxisLabels()) { value in
                    AxisValueLabel(format: DoubleToIntFormatStyle(), horizontalSpacing: 20)
                        .font(.system(.callout))
                        .foregroundStyle(.black)
                }
            })
            .chartXScale(domain: .automatic(includesZero: true, reversed: false))
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis(content: {
                AxisMarks(values: getXAxisLabels()) { value in
                    let anchor: UnitPoint = value.index == 0 ? .topLeading : (value.index == (value.count - 1) ? .topTrailing: .top)
                    AxisValueLabel(format: CustomFormatStyle(format: "HH:mm:ss", isUppercase: true),
                                   anchor: anchor,
                                   verticalSpacing: 10)
                    .font(.system(.callout))
                    .foregroundStyle(.black)
                }
            })
            .frame(width: 350, height: 450) // **Better Size**
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline) // Keeps the space minimal
    }
    
    func getYAxisLabels() -> [Double] {
        if let lastItem = (viewModel.stockPriceHistory[stockSymbol]?.compactMap{$0.price}.max() as? Double) {
            return [
                (lastItem - 100) > 0 ? lastItem - 100 : 0,
                (lastItem - 50) > 0 ? lastItem - 50 : 0,
                lastItem
            ]
        } else {
            return viewModel.stockPriceHistory[stockSymbol]?.compactMap{$0.price} ?? []
        }
    }
    
    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss" // 24-hour format
        return formatter.string(from: date)
    }
    
    
    func getXAxisLabels() -> [Date] {
        if let firstItem = viewModel.stockPriceHistory[stockSymbol]?.first?.timestamp as? Date,
           let lastItem = (viewModel.stockPriceHistory[stockSymbol]?.last?.timestamp as? Date) {
            let diff = (lastItem.timeIntervalSince1970) - (firstItem.timeIntervalSince1970)
            return [
                firstItem,
                firstItem.addingTimeInterval(diff/2),
                lastItem
            ]
        } else {
            return viewModel.stockPriceHistory[stockSymbol]?.compactMap{$0.timestamp} ?? []
        }
    }
}

#Preview {
    StockDetailsView(stockSymbol: "BINANCE:BTCUSDT", viewModel: StockListViewModel())
}


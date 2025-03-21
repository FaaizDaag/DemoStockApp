//
//  StockListView.swift
//  DemoStockApp
//
//  Created by Faaiz Daglawala on 3/21/25.
//

import SwiftUI

struct StockListView: View {
    @StateObject private var viewModel = StockListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.stocks) { stock in
                NavigationLink(destination: StockDetailsView(stockSymbol: stock.symbol, viewModel: viewModel)) {
                    HStack {
                        Text(stock.symbol)
                            .font(.headline)
                        Spacer()
                        Text(stock.price != nil ? "$\(stock.price!, specifier: "%.2f")" : "-")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Stock Prices")
        }
    }
}

struct StockCell: View {
    @Binding var stock: Stock
    var body: some View {
        HStack {
            Text(stock.symbol)
                .font(.headline)
            Spacer()
            Text(stock.price != nil ? "$\(stock.price!, specifier: "%.2f")" : "-")
                .foregroundColor(.green)
        }
    }
}

#Preview {
    StockListView()
}

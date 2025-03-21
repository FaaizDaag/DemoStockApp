//
//  StockListViewModel.swift
//  DemoStockApp
//
//  Created by Faaiz Daglawala on 3/21/25.
//

import SwiftUI
import Combine

/// ViewModel for handling stock data, including fetching stock prices from an API and receiving real-time updates via WebSocket.
class StockListViewModel: ObservableObject {
    
    /// Published property to store the latest stock prices.
    @Published var stocks: [Stock] = []
    
    @Published var stockPriceHistory: [String: [StockDataPoint]] = [:]
        
    /// WebSocket task for receiving live stock updates.
    private var webSocketTask: URLSessionWebSocketTask?
    
    /// Set to manage Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// API key for authentication with the stock data provider.
    private let apiKey = "cvdca91r01qm9khjvit0cvdca91r01qm9khjvitg"
    
    /// List of stock symbols to track. Added "BINANCE:ETHUSDT" for live update demo
    private let symbols = ["BINANCE:ETHUSDT", "BINANCE:BTCUSDT", "OANDA:GBP_USD"]
    
    private let maxDataPoints = 20
    
    /// Deinitializer to ensure WebSocket is disconnected when the ViewModel is deallocated.
    deinit {
        disconnectWebSocket()
    }
    
    /// Initializes the ViewModel by fetching stock prices and connecting to the WebSocket.
    init() {
        fetchStockPrices()
        connectWebSocket()
    }
    
    /// Fetches initial stock prices from the API.
    private func fetchStockPrices() {
        let group = DispatchGroup()
        var updatedStocks: [Stock] = []
        
        for symbol in symbols {
            group.enter()
            let urlString = "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(apiKey)"
            guard let url = URL(string: urlString) else { continue }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: [String: Double].self, decoder: JSONDecoder())
                .map { Stock(symbol: symbol, price: $0["c"]) } // Extract the stock price
                .replaceError(with: Stock(symbol: symbol, price: nil)) // Handle errors gracefully
                .sink(receiveValue: { stock in
                    updatedStocks.append(stock)
                    group.leave()
                })
                .store(in: &cancellables)
        }
        
        /// Update the stocks array once all network calls are completed.
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.stocks = updatedStocks
        }
    }
    
    /// Establishes a WebSocket connection to receive real-time stock price updates.
    private func connectWebSocket() {
        guard let url = URL(string: "wss://ws.finnhub.io?token=\(apiKey)") else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        subscribeToStocks()
        receiveMessages()
    }
    
    /// Sends subscription messages to the WebSocket to receive live updates for each stock symbol.
    private func subscribeToStocks() {
        for symbol in symbols {
            let message: [String: Any] = ["type": "subscribe", "symbol": symbol]
            if let jsonData = try? JSONSerialization.data(withJSONObject: message) {
                webSocketTask?.send(URLSessionWebSocketTask.Message.data(jsonData)) { error in
                    if let error = error {
                        print("❌ Subscription Error: \(error.localizedDescription)")
                    } else {
                        print("✅ Subscribed to \(symbol)")
                    }
                }
            }
        }
    }
    
    /// Continuously listens for WebSocket messages containing stock price updates.
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("✅ Received Data: \(data)")
                    self.handleWebSocketData(data)
                    
                case .string(let string):
                    print("✅ Received String: \(string)")
                    if let data = string.data(using: .utf8) {
                        self.handleWebSocketData(data)
                    }
                    
                @unknown default:
                    print("⚠️ Unknown WebSocket Message Format")
                }
                
                // Continue listening for the next message
                self.receiveMessages()
                
            case .failure(let error):
                print("❌ WebSocket Receive Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Parses and processes incoming WebSocket data.
    private func handleWebSocketData(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Case 1: Handling WebSocket trade response containing an array of stock updates.
                if let dataArray = json["data"] as? [[String: Any]], !dataArray.isEmpty {
                    // Group trades by symbol to process them efficiently.
                    let groupedTrades = Dictionary(grouping: dataArray, by: { $0["s"] as? String ?? "" })
                    
                    for (symbol, tradeList) in groupedTrades {
                        guard let latestTrade = tradeList.last, let price = latestTrade["p"] as? Double else { continue }
                        updateStockPrice(symbol: symbol, price: price)
                    }
                }
                // Case 2: Handling WebSocket response with a single trade object.
                else if let data = json["data"] as? [String: Any] {
                    processTradeData(data)
                }
            }
        } catch {
            print("❌ Failed to parse JSON: \(error.localizedDescription)")
        }
    }
    
    /// Processes individual trade data received from WebSocket.
    private func processTradeData(_ latestTrade: [String: Any]) {
        if let symbol = latestTrade["s"] as? String,
           let price = latestTrade["p"] as? Double {
            updateStockPrice(symbol: symbol, price: price)
        }
    }
    
    /// Updates the stock price in the `stocks` array.
    private func updateStockPrice(symbol: String, price: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let index = self.stocks.firstIndex(where: { $0.symbol == symbol }) {
                if self.stocks[index].price != price {  // Update only if price has changed
                    self.stocks[index].price = price
                    self.objectWillChange.send() // Notify views about the change
                }
            }
            
//           let lineChartData = LineChartData<Date,Double>(type: "stocks",
//                                       x: Date(),
//                                       y: price,
//                                       id: Double.random(in: 0...5000))
//            self.chartData.append(lineChartData)
//            // Save price history for the stock
            let dataPoint = StockDataPoint(timestamp: Date(), price: price)
            if self.stockPriceHistory[symbol] == nil {
                self.stockPriceHistory[symbol] = []
            }
            self.stockPriceHistory[symbol]?.append(dataPoint)            
        }
    }
    
    /// Closes the WebSocket connection when no longer needed.
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
}

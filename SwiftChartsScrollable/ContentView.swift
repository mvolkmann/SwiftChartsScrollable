import Charts
import SwiftUI

struct Stock: Equatable, Identifiable {
    var id: Date { date }
    var date: Date
    var price: Double

    init(date: Date, price: Double) {
        self.date = date
        self.price = price
    }
}

private func generateStocks() -> [Stock] {
    var stocks: [Stock] = []
    var date = Date()
    var price = 100.0
    for _ in 1 ... 365 {
        date = date.tomorrow
        price += Double.random(in: -3 ... 3)
        stocks.append(Stock(date: date, price: price))
    }
    return stocks
}

struct ContentView: View {
    @State private var rawSelectedDate: Date?
    @State private var scrollX = 0.0
    private let stocks = generateStocks()

    private let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "MMM d, yyyy"
    }

    private func annotation(for stock: Stock) -> some View {
        let date = dateFormatter.string(from: stock.date)
        return VStack(alignment: .leading) {
            Text(date)
            Text(String(format: "%.2f", stock.price))
        }
        .padding(5)
        .border(.gray)
    }

    private func ruleMark(selectedDate: Date) -> some ChartContent {
        // Find the index of the first Stock object
        // that is after the selected date.
        let index = stocks
            .firstIndex { $0.date > selectedDate }
            ?? stocks.count

        // Get the selected Stock object.
        let stock = stocks[index - 1]

        return RuleMark(x: .value("Selected", stock.date))
            .foregroundStyle(.gray.opacity(0.3))
            .offset(yStart: -10) // extend above chart
            .zIndex(-1) // behind LineMarks and PointMarks
            .annotation(
                position: .top, // above chart
                spacing: 0, // between top of RuleMark & annotation
                overflowResolution: .init(
                    x: .fit(to: .chart), // prevents horizontal spill
                    y: .disabled // allows annotation above chart
                )
            ) {
                annotation(for: stock)
            }
    }

    var body: some View {
        VStack {
            // TODO: What does this value mean?
            // TODO: How can this value be associated with a stock?
            Text("scrollX = \(scrollX)")
            Chart(stocks) { stock in
                LineMark(
                    x: .value("Date", stock.date),
                    y: .value("Price", stock.price)
                )
                .foregroundStyle(.red)
                .interpolationMethod(.catmullRom)

                if let rawSelectedDate {
                    ruleMark(selectedDate: rawSelectedDate)
                }
            }
            // .chartXSelection(value: $rawSelectedDate)

            // Annotations stop working when this is present!
            // See https://feedbackassistant.apple.com/feedback/12348843.
            .chartScrollableAxes(.horizontal)

            .chartXVisibleDomain(length: 30 * 24 * 60 * 60) // sec. in 30 days

            .chartScrollPosition(x: $scrollX)

            .padding(.top, 40) // leaves room for annotations
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

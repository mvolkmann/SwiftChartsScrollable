import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var tomorrow: Date {
        let begin = startOfDay
        return Calendar.current.date(byAdding: .day, value: 1, to: begin)!
    }
}

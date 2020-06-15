import Foundation

public final class SharedDateFormatter {
    public static let shared = SharedDateFormatter()
    private var dateFormatter: DateFormatter?
   
    private init() {
        dateFormatter = DateFormatter()
    }
    
    public func date(from dateString: String, formatter: String) -> Date? {
        dateFormatter?.dateFormat = formatter
        let formattedDate = dateFormatter?.date(from: dateString)
        return formattedDate
    }
    
    public func string(from date: Date,
                       formatter: String,
                       locale: Locale? = nil,
                       timeZone: TimeZone? = nil) -> String {
        dateFormatter?.dateFormat = formatter
        if let locale = locale {
            dateFormatter?.locale = locale
        }
        if let tz = timeZone {
            dateFormatter?.timeZone = tz
        }
        let formattedString = dateFormatter?.string(from: date)
        return formattedString ?? ""
    }
}

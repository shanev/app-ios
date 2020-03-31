import Foundation

struct CEN {
    let CEN: String
    let timestamp: Int64

    init(CEN: String, timestamp: Int64 = Int64(Date().timeIntervalSince1970)) {
        self.CEN = CEN
        self.timestamp = timestamp
    }
}

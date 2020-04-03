struct CENReport: Codable, CustomStringConvertible {
    let id: String
    let report: String
    let timestamp: Int64
    let keys: String = "TODO" // TODO

    var description: String {
        "id: \(id), report: \(report), timestamp: \(timestamp), keys: \(keys)"
    }
}

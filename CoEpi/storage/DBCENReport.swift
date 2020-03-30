import RealmSwift

final class DBCENReport : Object {

    // CENReportID is a local internal attribute only
    @objc dynamic var CENReportID: String = ""

    // report is a JSON Object (could be ByteArray) representing a report keyed by 2-4 CENKeys
    // Different app designs will have different ideas about what will go inside this report, differentiated by reportMimeType and other metadata that can be added to this
    @objc dynamic var report: String = ""

    // CENKeys is a comma-separated string (should be: List of String) of 128bit CEN Keys
    @objc dynamic  var CENKeys: String? = ""

    // The MIME Type of the above data, enabling everyone to build apps with different format
    @objc dynamic var reportMimeType: String? = ""
    @objc dynamic var reportTimestamp: Int64 = 0

    // isuser is true when the reporter is this user
    @objc dynamic var isUser: Bool = false
    
    override static func primaryKey() -> String? {
        return "CENReportID"
    }
    
    required init(_report: String, _cenKeys: String, _ts: Int64) {
        self.CENReportID = NSUUID().uuidString
        self.report = _report
        self.CENKeys = _cenKeys
        self.reportTimestamp = _ts
    }
    
    required init() {
        //fatalError("init() has not been implemented")
        self.CENReportID = NSUUID().uuidString
        self.reportTimestamp = 0
    }
}

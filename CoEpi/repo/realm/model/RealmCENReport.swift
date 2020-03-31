import RealmSwift
import Foundation

final class RealmCENReport : Object {

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

    convenience init(_ report: CENReport) {
        self.init()

        self.CENReportID = report.CENReportID
        self.report = report.report
        self.CENKeys = report.CENKeys
        self.reportTimestamp = report.reportTimestamp
    }
}

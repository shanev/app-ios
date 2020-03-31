import Foundation
import CryptoKit
import RealmSwift
import Security

struct CENKey : Codable {
    var cenKey: String?
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970)
}

//
//  Utils.swift
//  coepiiosdemo
//
//  Created by Rodney Witcher on 3/26/20.
//  Copyright © 2020 coepi. All rights reserved.
//

import Foundation

let CENKeyLifetimeInSeconds: Int64 = 2*60 //TODO: revert back to 7*86400
let CENLifetimeInSeconds: Int64 = 1*60 //TODO: revert back to 15*60

func roundedTimestamp(ts : Int64) -> Int64 {
    return Int64(ts / CENKeyLifetimeInSeconds)*CENKeyLifetimeInSeconds
}

func base64ToString(b64: String) -> String {
    let decodedData = Data(base64Encoded: b64)!
    return decodedData.compactMap { String(format: "%02x", $0) }.joined() //String(data: decodedData, encoding: .utf8)!
}

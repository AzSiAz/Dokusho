import Foundation
import Harmony
import CloudKit
import GRDB

extension Scraper: HRecord {    
    public var zoneID: CKRecordZone.ID {
        return CKRecordZone.ID(
            zoneName: "Scraper",
            ownerName: CKCurrentUserDefaultName
        )
    }

    public var record: CKRecord {
        try! CKRecordEncoder(zoneID: zoneID).encode(self)
    }
}

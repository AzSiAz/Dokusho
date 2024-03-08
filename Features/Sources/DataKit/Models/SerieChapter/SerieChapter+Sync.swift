import Foundation
import Harmony
import CloudKit
import GRDB

extension SerieChapter: HRecord {
    public var zoneID: CKRecordZone.ID {
        return CKRecordZone.ID(
            zoneName: "SerieChapter",
            ownerName: CKCurrentUserDefaultName
        )
    }
    
    public var record: CKRecord {
        try! CKRecordEncoder(zoneID: zoneID).encode(self)
    }
}

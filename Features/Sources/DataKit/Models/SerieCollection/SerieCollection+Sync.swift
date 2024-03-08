import Foundation
import Harmony
import CloudKit
import GRDB

extension SerieCollection: HRecord {
    public var zoneID: CKRecordZone.ID {
        return CKRecordZone.ID(
            zoneName: "SerieCollection",
            ownerName: CKCurrentUserDefaultName
        )
    }
    
    public var record: CKRecord {
        try! CKRecordEncoder(zoneID: zoneID).encode(self)
    }
}

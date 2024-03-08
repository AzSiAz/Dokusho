import Foundation
import Harmony
import CloudKit
import GRDB

extension Serie: HRecord {    
    public var zoneID: CKRecordZone.ID {
        return CKRecordZone.ID(
            zoneName: "Serie",
            ownerName: CKCurrentUserDefaultName
        )
    }
    
    public var record: CKRecord {
        try! CKRecordEncoder(zoneID: zoneID).encode(self)
    }
}

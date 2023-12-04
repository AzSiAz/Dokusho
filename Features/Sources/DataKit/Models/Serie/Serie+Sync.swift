import Foundation
import Harmony
import CloudKit
import GRDB

extension Serie: HRecord {    
    public mutating func updateChanges(db: Database, ckRecord: CKRecord) throws {}
    
    public var archivedRecordData: Data? {
        get { Data() }
        set(newValue) { }
    }
    
    public var zoneID: CKRecordZone.ID {
        return .default
    }
    
    public var record: CKRecord {
        try! CKRecordEncoder(zoneID: zoneID).encode(self)
    }
}

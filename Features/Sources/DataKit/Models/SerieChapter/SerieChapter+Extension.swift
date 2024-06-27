import Foundation
import GRDB

public extension SerieChapter {
    typealias InternalID = String

    enum CodingKeys: String, CodingKey {
        case id, internalID, title, subTitle, uploadedAt, volume, chapter, readAt, progress, externalUrl, serieID
    }
}

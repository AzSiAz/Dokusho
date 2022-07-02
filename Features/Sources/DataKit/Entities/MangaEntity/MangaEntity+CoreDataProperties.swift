//
//  MangaEntity+CoreDataProperties.swift
//  Dokusho
//
//  Created by Stephan Deumier on 30/06/2022.
//
//

import Foundation
import CoreData


extension MangaEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MangaEntity> {
        return NSFetchRequest<MangaEntity>(entityName: "MangaEntity")
    }

    @NSManaged public var mangaId: String
    @NSManaged public var title: String
    @NSManaged public var cover: URL
    @NSManaged public var synopsis: String
    @NSManaged public var status: MangaEntityStatus
    @NSManaged public var type: MangaEntityType
    @NSManaged public var unreadChapters: Int16
    @NSManaged public var readChapters: Int16
    @NSManaged public var scraperId: UUID
    @NSManaged public var collection: CollectionEntity
    @NSManaged public var genres: Set<GenreEntity>
    @NSManaged public var alternatesTitles: Set<AlternateTitleEntity>
    @NSManaged public var peoples: Set<PeopleEntity>
    @NSManaged public var chapters: Set<ChapterEntity>

}

// MARK: Generated accessors for genres
extension MangaEntity {

    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: GenreEntity)

    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: GenreEntity)

    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: Set<GenreEntity>)

    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: Set<GenreEntity>)

}

// MARK: Generated accessors for alternatesTitles
extension MangaEntity {

    @objc(addAlternatesTitlesObject:)
    @NSManaged public func addToAlternatesTitles(_ value: AlternateTitleEntity)

    @objc(removeAlternatesTitlesObject:)
    @NSManaged public func removeFromAlternatesTitles(_ value: AlternateTitleEntity)

    @objc(addAlternatesTitles:)
    @NSManaged public func addToAlternatesTitles(_ values: Set<AlternateTitleEntity>)

    @objc(removeAlternatesTitles:)
    @NSManaged public func removeFromAlternatesTitles(_ values: Set<AlternateTitleEntity>)

}

// MARK: Generated accessors for peoples
extension MangaEntity {

    @objc(addPeoplesObject:)
    @NSManaged public func addToPeoples(_ value: PeopleEntity)

    @objc(removePeoplesObject:)
    @NSManaged public func removeFromPeoples(_ value: PeopleEntity)

    @objc(addPeoples:)
    @NSManaged public func addToPeoples(_ values: Set<PeopleEntity>)

    @objc(removePeoples:)
    @NSManaged public func removeFromPeoples(_ values: Set<PeopleEntity>)

}

// MARK: Generated accessors for chapters
extension MangaEntity {

    @objc(addChaptersObject:)
    @NSManaged public func addToChapters(_ value: ChapterEntity)

    @objc(removeChaptersObject:)
    @NSManaged public func removeFromChapters(_ value: ChapterEntity)

    @objc(addChapters:)
    @NSManaged public func addToChapters(_ values: Set<ChapterEntity>)

    @objc(removeChapters:)
    @NSManaged public func removeFromChapters(_ values: Set<ChapterEntity>)

}

extension MangaEntity : Identifiable {}

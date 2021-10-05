//
//  MangaEntity+CoreDataClass.swift
//  MangaEntity
//
//  Created by Stephan Deumier on 04/09/2021.
//
//

import Foundation
import CoreData

@objc(MangaEntity)
public class MangaEntity: NSManagedObject {}

extension MangaEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MangaEntity> {
        return NSFetchRequest<MangaEntity>(entityName: "MangaEntity")
    }
    
    @NSManaged public var cover: URL?
    @NSManaged public var mangaId: String?
    @NSManaged public var statusRaw: String?
    @NSManaged public var synopsis: String?
    @NSManaged public var title: String?
    @NSManaged public var typeRaw: String?
    @NSManaged public var lastChapterUploadDate: Date?
    @NSManaged public var lastUserAction: Date?
    @NSManaged public var sourceId: UUID

    @NSManaged public var collection: CollectionEntity?
    @NSManaged public var alternateTitles: Set<AlternateTitlesEntity>?
    @NSManaged public var authorsAndArtists: Set<AuthorAndArtistEntity>?
    @NSManaged public var chapters: Set<ChapterEntity>?
    @NSManaged public var genres: Set<GenreEntity>?
    
    
}

    // MARK: Generated accessors for alternateTitles
extension MangaEntity {
    
    @objc(addAlternateTitlesObject:)
    @NSManaged public func addToAlternateTitles(_ value: AlternateTitlesEntity)
    
    @objc(removeAlternateTitlesObject:)
    @NSManaged public func removeFromAlternateTitles(_ value: AlternateTitlesEntity)
    
    @objc(addAlternateTitles:)
    @NSManaged public func addToAlternateTitles(_ values: Set<AlternateTitlesEntity>)
    
    @objc(removeAlternateTitles:)
    @NSManaged public func removeFromAlternateTitles(_ values: Set<AlternateTitlesEntity>)
    
}

    // MARK: Generated accessors for authorsAndArtists
extension MangaEntity {
    
    @objc(addAuthorsAndArtistsObject:)
    @NSManaged public func addToAuthorsAndArtists(_ value: AuthorAndArtistEntity)
    
    @objc(removeAuthorsAndArtistsObject:)
    @NSManaged public func removeFromAuthorsAndArtists(_ value: AuthorAndArtistEntity)
    
    @objc(addAuthorsAndArtists:)
    @NSManaged public func addToAuthorsAndArtists(_ values: Set<AuthorAndArtistEntity>)
    
    @objc(removeAuthorsAndArtists:)
    @NSManaged public func removeFromAuthorsAndArtists(_ values: Set<AuthorAndArtistEntity>)
    
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

extension MangaEntity : Identifiable {}

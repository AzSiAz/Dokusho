//
//  AuthorAndArtistEntity+CoreDataClass.swift
//  AuthorAndArtistEntity
//
//  Created by Stephan Deumier on 04/09/2021.
//
//

import Foundation
import CoreData

@objc(AuthorAndArtistEntity)
public class AuthorAndArtistEntity: NSManagedObject {}

extension AuthorAndArtistEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorAndArtistEntity> {
        return NSFetchRequest<AuthorAndArtistEntity>(entityName: "AuthorAndArtistEntity")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var typeRaw: String?
    @NSManaged public var mangas: Set<MangaEntity>?
    
}

    // MARK: Generated accessors for mangas
extension AuthorAndArtistEntity {
    
    @objc(addMangasObject:)
    @NSManaged public func addToMangas(_ value: MangaEntity)
    
    @objc(removeMangasObject:)
    @NSManaged public func removeFromMangas(_ value: MangaEntity)
    
    @objc(addMangas:)
    @NSManaged public func addToMangas(_ values: Set<MangaEntity>)
    
    @objc(removeMangas:)
    @NSManaged public func removeFromMangas(_ values: Set<MangaEntity>)
    
}

extension AuthorAndArtistEntity : Identifiable {}

//
//  Provider.swift
//  Dokusho
//
//  Created by Stef on 05/10/2021.
//

import WidgetKit
import Intents

struct Provider: IntentTimelineProvider {
    let ctx = PersistenceController.shared.container.viewContext
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ChooseCollectionIntent(), mangas: [
            SmallMangaEntry(title: "Akai Mi Hajiketa", cover: "https://cover.nep.li/cover/Akai-Mi-Hajiketa.jpg")
        ])
    }

    func getSnapshot(for configuration: ChooseCollectionIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let mangas = MangaEntity.fetchLatestUpdate(ctx: ctx, collectionUUID: (configuration.collection?.identifier!)!)
        let entry = SimpleEntry(date: Date(), configuration: configuration, mangas: SmallMangaEntry.fromMangaEntity(for: mangas))
        
        completion(entry)
    }

    func getTimeline(for configuration: ChooseCollectionIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let mangas = MangaEntity.fetchLatestUpdate(ctx: ctx, collectionUUID: (configuration.collection?.identifier!)!)
        let entry = SimpleEntry(date: Date(), configuration: configuration, mangas: SmallMangaEntry.fromMangaEntity(for: mangas))

        let entries: [SimpleEntry] = [entry]

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

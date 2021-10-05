//
//  Widget.swift
//  DokushoWidgetExtension
//
//  Created by Stef on 05/10/2021.
//

import WidgetKit
import SwiftUI

struct DokushoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text(entry.mangas.first?.title ?? "")
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .zIndex(100)
            Image(uiImage: UIImage(data: entry.mangas.first!.cover)!)
                .resizable()
                .scaledToFit()

        }
    }
}

struct LatestMangaWidget: Widget {
    let kind: String = WidgetKind.latestMangaWidget.rawValue

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ChooseCollectionIntent.self, provider: Provider()) { entry in
            DokushoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Latest Update")
        .description("Provide latest manga update in selected collection, manga number depends on widget size")
        .supportedFamilies([.systemSmall])
    }
}

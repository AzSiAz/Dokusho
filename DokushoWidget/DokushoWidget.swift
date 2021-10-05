//
//  DokushoWidget.swift
//  DokushoWidget
//
//  Created by Stef on 05/10/2021.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct DokushoWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        LatestMangaWidget()
    }
}

import SwiftUI
import SwiftData
import DataKit
import SharedUI

// TODO: Refactor to only fetch source in parent view and use a bindable
struct SourceRow: View {
    @Environment(ScraperService.self) var svc

    @Bindable var scraper: Scraper
    
    init(scraper: Scraper) {
        self.scraper = scraper
    }
    
    var body: some View {
        Group {
            HStack {
                RemoteImageCacheView(url: scraper.icon, contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .padding(.trailing)
                
                VStack(alignment: .leading) {
                    Text(scraper.name)
                    Text(scraper.language.rawValue)
                        .font(.callout.italic())
                }
                .padding(.leading, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            .contentShape(RoundedRectangle(cornerRadius: 5))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { scraper.isActive.toggle() }) {
                    Label(scraper.isActive ? "DEACTIVE" : "ACTIVE", systemImage: scraper.isActive ? "eye.slash" : "eye")
                }
                .tint(scraper.isActive ? .red : .blue)
            }
        }
        .buttonStyle(.plain)
//        .task { updateIfSourceExist() }
    }
    
    func updateIfSourceExist() {
//        if let scraper = sourceData.scraper {
//            scraper.update(source: sourceData.source)
//        }
    }
}

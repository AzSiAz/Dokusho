import SwiftUI
import SwiftData
import DataKit
import SharedUI

struct SourceRow: View {
    @Harmony var harmony
    
    var scraper: Scraper
    
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
                Button(action: { toggleIsActive() }) {
                    Label(scraper.isActive ? "Deactivate" : "Activate", systemImage: scraper.isActive ? "eye.slash" : "eye")
                }
                .tint(scraper.isActive ? .red : .blue)
            }
        }
        .buttonStyle(.plain)
    }
    
    func toggleIsActive() {
        var sc = scraper
        sc.toggleIsActive()
        
        Task { [sc] in
            try? await harmony.save(record: sc)
        }
    }
}

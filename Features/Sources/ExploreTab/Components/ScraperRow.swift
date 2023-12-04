import Foundation
import SwiftUI
import DataKit
import SharedUI

struct ScraperRow: View {
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
        }
        .buttonStyle(.plain)
    }
}

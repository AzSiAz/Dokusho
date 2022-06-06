import XCTest
@testable import MangaScraper

final class MangaScraperTests: XCTestCase {
    func testExample() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MangaScraperService.shared.getSource(sourceId: UUID(uuidString: "FFAECF22-DBB3-4B13-B4AF-665DC31CE775")!)?.id, NepNepSource.MangaSee123Source.id)
        XCTAssertEqual(MangaScraperService.shared.getSource(sourceId: UUID(uuidString: "B6127CD7-A9C0-4610-8491-47DFCFD90DBC")!)?.id, NepNepSource.Manga4LifeSource.id)
        XCTAssertEqual(MangaScraperService.shared.getSource(sourceId: UUID(uuidString: "3599756d-8fa0-4ca2-aafc-096c3d776ae1")!)?.id, MangaDex.shared.id)

        do {
//            let d = try await MangaDex.shared.fetchMangaDetail(id: "ac28f3f4-1bfd-491c-8403-0162379f953d")
//            print(d.title)
//            print(d.chapters)
            let d = try await MangaDex.shared.fetchLatestUpdates(page: 1)
            let d2 = try await MangaDex.shared.fetchLatestUpdates(page: 1)
//            let d = try await NepNepSource.MangaSee123Source.fetchSearchManga(query: "Isekai Kae", page: 1)
//            let d = try await MangaDex.shared.fetchSearchManga(query: "Isekai Kae", page: 1)
            
            print(d.mangas.first)
            print(d2.mangas.first)
        } catch {
            print(error)
        }
    }
}


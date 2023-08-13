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
            let d = try await MangaDex.shared.fetchMangaDetail(id: "38f386ce-f2dc-4f2b-99f9-522eab56078d")
            print(d.title)
            print(d.chapters)
        } catch {
            print(error)
        }
    }
}


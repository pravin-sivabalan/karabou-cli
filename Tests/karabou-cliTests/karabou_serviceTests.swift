import XCTest

@testable import karabou_cli

class KarabouCLITests: XCTestCase {
    let GOOGLE_CHROME = App(
        name: "Google Chrome",
        bundleIdentifier: "com.google.Chrome",
        appPath: "/Applications/Google Chrome.app"
    )
    let VISUAL_STUDIO_CODE = App(
        name: "Visual Studio Code",
        bundleIdentifier: "com.microsoft.VSCode",
        appPath: "/Applications/Visual Studio Code.app"
    )
    let ITERM2 = App(
        name: "iTerm2",
        bundleIdentifier: "com.googlecode.iterm2",
        appPath: "/Applications/iTerm.app"
    )
    let CURSOR = App(
        name: "Cursor",
        bundleIdentifier: "com.cursor.app",
        appPath: "/Applications/Cursor.app"
    )
    let APPLE_NOTES = App(
        name: "Apple Notes",
        bundleIdentifier: "com.apple.Notes",
        appPath: "/Applications/Notes.app"
    )
    let APPLE_MUSIC = App(
        name: "Apple Music",
        bundleIdentifier: "com.apple.Music",
        appPath: "/Applications/Music.app"
    )
    let APPLE_MAIL = App(
        name: "Apple Mail",
        bundleIdentifier: "com.apple.Mail",
        appPath: "/Applications/Mail.app"
    )
    let SPOTIFY = App(
        name: "Spotify",
        bundleIdentifier: "com.spotify.client",
        appPath: "/Applications/Spotify.app"
    )
    let GMAIL_WEB_APP = App(
        name: "Gmail Web App",
        bundleIdentifier: "com.google.Gmail",
        appPath:
            "/Users/ps/Applications/Chrome Apps.localized/Gmail.app/Contents/MacOS/app_mode_loader"
    )

    func testSearchService_chrome_match() throws {
        let query = "chrome"
        let apps = [GOOGLE_CHROME, ITERM2, CURSOR, APPLE_NOTES, APPLE_MUSIC, APPLE_MAIL, GMAIL_WEB_APP]

        let results = SearchService.search(query: query, items: apps, resultLimit: 3)

        XCTAssertEqual(results[0].name, "Google Chrome")
    }

    func testSearchService_cursr_match() throws {
        let query = "cursr"
        let apps = [GOOGLE_CHROME, ITERM2, CURSOR, APPLE_NOTES, APPLE_MUSIC, APPLE_MAIL]

        let results = SearchService.search(query: query, items: apps, resultLimit: 3)

        XCTAssertEqual(results[0].name, "Cursor")
    }

    func testSearchService_appl_multipleMatches() throws {
        let query = "appl"
        let apps = [GOOGLE_CHROME, ITERM2, CURSOR, APPLE_NOTES, APPLE_MUSIC, APPLE_MAIL]

        let results = SearchService.search(query: query, items: apps, resultLimit: 3)

        XCTAssertEqual(results[0].name, "Apple Notes")
        XCTAssertEqual(results[1].name, "Apple Music")
        XCTAssertEqual(results[2].name, "Apple Mail")
    }
    
    func testSearchService_gmail_match() throws {
        let query = "gmail"
        let apps = [GOOGLE_CHROME, ITERM2, CURSOR, APPLE_NOTES, APPLE_MUSIC, APPLE_MAIL, GMAIL_WEB_APP]
        
        let results = SearchService.search(query: query, items: apps, resultLimit: 3)
        
        XCTAssertEqual(results[0].name, "Gmail Web App")
    }

    func testSearchService_microsoft_match() throws {
        let query = "microsoft"
        let apps = [VISUAL_STUDIO_CODE, GOOGLE_CHROME, ITERM2, CURSOR, APPLE_NOTES, APPLE_MUSIC, APPLE_MAIL, GMAIL_WEB_APP]
        
        let results = SearchService.search(query: query, items: apps, resultLimit: 3)
        
        XCTAssertEqual(results[0].name, "Visual Studio Code")
    }

    func testSearchService_gogle_match() throws {
        let query = "gogle"
        let apps = [GOOGLE_CHROME, ITERM2, CURSOR, APPLE_NOTES, APPLE_MUSIC, APPLE_MAIL, GMAIL_WEB_APP]
        
        let results = SearchService.search(query: query, items: apps, resultLimit: 3)
        
        XCTAssertEqual(results[0].name, "Google Chrome")
    }

    func testSearchService_cursor_noMatch() throws {
        let query = "cursor_no_match"
        let apps = [GOOGLE_CHROME, ITERM2, CURSOR, APPLE_NOTES, APPLE_MUSIC, APPLE_MAIL, GMAIL_WEB_APP]
        
        let results = SearchService.search(query: query, items: apps, resultLimit: 3)
        
        XCTAssertEqual(results.count, 0)
    }

    func testConfigManager_addAppOpen() throws {
        let config = createEmptyConfig()
        let manager = KarabinerConfigManager(
            karabinerConfig: config, destinationRuleName: "KarabouManaged-OpenApps")

        manager.addAppOpen(keyCode: "z", modifier: "right_command", app: APPLE_MUSIC)
        
        XCTAssertEqual(manager.hasManipulator(keyCode: "z"), true)
    }

    func testConfigManager_removeAppOpen() throws {
        let config = createEmptyConfig()
        let manager = KarabinerConfigManager(
            karabinerConfig: config, destinationRuleName: "KarabouManaged-OpenApps")

        manager.addAppOpen(keyCode: "z", modifier: "right_command", app: APPLE_MUSIC)
        manager.remove(keyCode: "z", modifier: "right_command")

        XCTAssertEqual(manager.hasManipulator(keyCode: "z"), false)
    }

    func testGoldenDiff1() throws {
        let inputUrl = Bundle.module.url(forResource: "input_golden_config_1", withExtension: "json")
        let config = try FileService.readJsonFile(url: inputUrl!) as KarabinerConfig

        // TODO: add a file path test case
        let manager = KarabinerConfigManager(
            karabinerConfig: config, destinationRuleName: "KarabouManaged-OpenApps")
        manager.addAppOpen(keyCode: "z", modifier: "right_command", app: APPLE_MUSIC)
        // manager.remove(keyCode: "j", modifier: "right_command")
        let actualConfig = manager.getKarabinerConfig()

        let outputUrl = Bundle.module.url(forResource: "output_golden_config_1", withExtension: "json")
        let expectedConfig = try FileService.readJsonFile(url: outputUrl!) as KarabinerConfig
        XCTAssertEqual(actualConfig, expectedConfig)
    }

    private func createEmptyConfig() -> KarabinerConfig {
        return KarabinerConfig(
            global: Global(showInMenuBar: true),
            profiles: [Profile(
                complexModifications: ComplexModifications(rules: []),
                devices: [],
                name: "Default",
                selected: true,
                virtualHIDKeyboard: nil
            )])
    }

}

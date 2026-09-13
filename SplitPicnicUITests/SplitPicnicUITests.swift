import XCTest

@MainActor
final class SplitPicnicUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchHomeAndSlice() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress"]
        app.launch()
        XCTAssertTrue(app.staticTexts["home-title"].waitForExistence(timeout: 6))
        saveShot("home")
        XCTAssertTrue(app.buttons["play-button"].exists)
        app.buttons["play-button"].tap()
        let dish = app.descendants(matching: .any)["dish"]
        XCTAssertTrue(dish.waitForExistence(timeout: 6))
        XCTAssertTrue(app.descendants(matching: .any)["swipe-prompt"].exists)
        saveShot("play")
        let start = dish.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18))
        let end = dish.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
        start.press(forDuration: 0.05, thenDragTo: end)
        XCTAssertTrue(app.staticTexts["result-title"].waitForExistence(timeout: 8))
        saveShot("result")
        XCTAssertTrue(app.buttons["next-level-button"].exists)
    }

    func testTutorialFits() throws {
        let app = XCUIApplication()
        app.launchArguments = ["reset-progress"]
        app.launch()
        XCTAssertTrue(app.buttons["tutorial-next"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.descendants(matching: .any)["tutorial-cut-clip"].exists)
        XCTAssertTrue(app.buttons["tutorial-replay"].exists)
        app.buttons["tutorial-replay"].tap()
        Thread.sleep(forTimeInterval: 1.5)
        saveShot("tutorial-cut-swipe")
        Thread.sleep(forTimeInterval: 2.3)
        saveShot("tutorial-cut-separated")
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["tutorial-serving-clip"].exists)
        Thread.sleep(forTimeInterval: 2.3)
        saveShot("tutorial-serving-motion")
        Thread.sleep(forTimeInterval: 1.4)
        saveShot("tutorial-serving-arrived")
        app.buttons["tutorial-next"].tap()
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["dish"].waitForExistence(timeout: 6))
        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(app.staticTexts["home-title"].waitForExistence(timeout: 6))
    }

    func testTutorialCanBeReplayedFromSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress"]
        app.launch()
        app.buttons["home-settings"].tap()
        XCTAssertTrue(app.buttons["settings-tutorial"].waitForExistence(timeout: 6))
        app.buttons["settings-tutorial"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["tutorial-cut-clip"].waitForExistence(timeout: 6))
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["tutorial-serving-clip"].exists)
        app.buttons["tutorial-next"].tap()
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.buttons["settings-tutorial"].waitForExistence(timeout: 6))
    }

    func testHintShowsAnimatedPathAndTutorial() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress"]
        app.launch()
        app.buttons["play-button"].tap()
        XCTAssertTrue(app.buttons["hint-button"].waitForExistence(timeout: 6))
        app.buttons["hint-button"].tap()
        XCTAssertTrue(app.staticTexts["hint-guide-text"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.buttons["hint-demo-button"].exists)
        Thread.sleep(forTimeInterval: 1.5)
        saveShot("hint-animated")
        app.buttons["hint-button"].tap()
        XCTAssertTrue(app.staticTexts["hint-guide-text"].exists)
        app.buttons["hint-demo-button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["tutorial-cut-clip"].waitForExistence(timeout: 6))
        app.buttons["tutorial-back"].tap()
        XCTAssertTrue(app.staticTexts["hint-guide-text"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.descendants(matching: .any)["dish"].exists)
    }

    func testDetailedLateLevelFits() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress", "ui-level=9"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["dish"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.descendants(matching: .any)["swipe-prompt"].exists)
        saveShot("play-detailed")
        let dish = app.descendants(matching: .any)["dish"]
        let start = dish.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18))
        let end = dish.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
        start.press(forDuration: 0.05, thenDragTo: end)
        XCTAssertTrue(app.staticTexts["fail-title"].waitForExistence(timeout: 8))
        saveShot("fail")
    }

    func testCurvedCutRendersAsTwoCurvedPieces() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress", "ui-level=1", "ui-curved-preview"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["dish"].waitForExistence(timeout: 6))
        saveShot("curved-cut")
    }

    func testVariedGuestPairFits() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress", "ui-level=3"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["dish"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.descendants(matching: .any)["guest-dog-woodland"].exists)
        saveShot("play-varied-guests")
    }

    func testPicnicThemeChangesDuringProgress() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress", "ui-progress-map", "ui-level=4"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["dish"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["Berry Picnic"].exists)
        saveShot("play-changing-theme")
    }

    func testWorldsDailyCollectionSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "reset-progress", "ui-progress-map"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 6))

        app.buttons["worlds-button"].tap()
        XCTAssertTrue(app.staticTexts["Pizza Park"].waitForExistence(timeout: 5))
        saveShot("worlds")
        app.buttons["back-button"].tap()

        app.buttons["daily-button"].tap()
        XCTAssertTrue(app.buttons["daily-play-button"].waitForExistence(timeout: 5))
        saveShot("daily")
        app.buttons["back-button"].tap()

        app.buttons["collection-button"].tap()
        XCTAssertTrue(app.staticTexts["Pizza Party"].waitForExistence(timeout: 5))
        saveShot("collection")
        app.buttons["back-button"].tap()

        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        saveShot("settings")
    }

    private func saveShot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let dir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("docs/screenshots", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try? shot.pngRepresentation.write(to: dir.appendingPathComponent("\(name).png"))
    }
}

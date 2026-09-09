import XCTest

final class SplitPicnicUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchHomeAndSlice() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.staticTexts["home-title"].waitForExistence(timeout: 6))
        saveShot("home")
        XCTAssertTrue(app.buttons["play-button"].exists)
        app.buttons["play-button"].tap()
        XCTAssertTrue(app.buttons["slice-button"].waitForExistence(timeout: 6))
        saveShot("play")
        app.buttons["slice-button"].tap()
        XCTAssertTrue(app.staticTexts["result-title"].waitForExistence(timeout: 8))
        saveShot("result")
        XCTAssertTrue(app.buttons["next-level-button"].exists)
    }

    func testWorldsDailyCollectionSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
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
    }
}

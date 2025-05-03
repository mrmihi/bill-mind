import XCTest

final class billMindUITests: XCTestCase {

  var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["-UITest"]
    app.launch()
  }

  func testAddBillFlowShowsInList() {
    let addTab = app.tabBars.buttons["Add"]
    XCTAssertTrue(addTab.waitForExistence(timeout: 2))
    addTab.tap()

    let nameField = app.textFields["Bill name"]
    XCTAssertTrue(nameField.waitForExistence(timeout: 1))
    nameField.tap()
    nameField.typeText("Lunch")

    let amountField = app.textFields["Amount (LKR)"]
    amountField.tap()
    amountField.typeText("150")

    app.swipeUp()
    let saveButton = app.buttons["Save"]
    XCTAssertTrue(saveButton.isEnabled)
    saveButton.tap()

    let billsTab = app.tabBars.buttons["Bills"]
    billsTab.tap()

    let lunchCell = app.staticTexts["Lunch"]
    XCTAssertTrue(lunchCell.waitForExistence(timeout: 2))

    XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "LKR 150")).element.exists)
  }
}

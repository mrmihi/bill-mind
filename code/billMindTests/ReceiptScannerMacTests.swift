#if targetEnvironment(macCatalyst)
import XCTest
@testable import billMind

/// Simple compile-time test cases for Mac Catalyst-specific UI components.
/// The goal is to ensure that Mac-only views can be created without crashing.
final class ReceiptScannerMacTests: XCTestCase {

    /// Verifies that the Mac-specific `ReceiptScannerView` can be instantiated.
    func testReceiptScannerViewInstantiation() {
        // The view is created; further UI assertions would require running in a
        // full UI test environment which is outside this unit-test's scope.
        let view = ReceiptScannerView()
        XCTAssertNotNil(view)
    }
}
#endif 
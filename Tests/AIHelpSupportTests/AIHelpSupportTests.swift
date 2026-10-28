import XCTest
import UIKit
import AIHelpSupport

final class AIHelpSupportTests: XCTestCase {
    func testSDKVersion() {
        XCTAssertEqual(AIHelpSupportSDK.getVersion(), "6.3.0")
    }

    func testSDKFindsPackagedResources() throws {
        // Exercise the vendor's lookup, rather than only checking Bundle.module.
        let tool = try XCTUnwrap(NSClassFromString("AHSystemTool") as? NSObject.Type)
        let selector = NSSelectorFromString("resourceBundle")
        XCTAssertTrue(tool.responds(to: selector))
        let bundle = try XCTUnwrap(tool.perform(selector)?.takeUnretainedValue() as? Bundle)
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: bundle.bundleURL.appendingPathComponent("Image/btn_send.png").path
        ))
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: bundle.bundleURL.appendingPathComponent("lan/en.lproj/Localizable.strings").path
        ))
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: bundle.bundleURL.appendingPathComponent("lan/zh-CN.lproj/Localizable.strings").path
        ))
        // Static Objective-C categories require the host's -ObjC linker flag.
        let imageSelector = NSSelectorFromString("AH_getBundleImageWithName:")
        let imageClass: NSObject.Type = UIImage.self
        guard imageClass.responds(to: imageSelector) else {
            XCTFail("Add -ObjC to the host target's Other Linker Flags")
            return
        }
        let image = imageClass.perform(imageSelector, with: "btn_send")?.takeUnretainedValue()
        XCTAssertNotNil(image as? UIImage)
    }
}

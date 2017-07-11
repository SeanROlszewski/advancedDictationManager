import XCTest
@testable import Dictation_manager

class DictationCommandParserTests: XCTestCase {
    
    func testParsing() {
        
        let path = Bundle(for: DictationCommandParserTests.self).path(forResource: "ExampleDictationCommands", ofType: "plist")!
        let commands = DictationCommand.Parser.parse(fileAt: path)
        
        guard let command = commands.first else {
            XCTFail("it should have parsed out a command")
            return
        }

        XCTAssert(command.phoneticName == "Run my program")
        XCTAssertEqual(command.lastModifiedDate, Date(timeIntervalSinceReferenceDate: 0))

        guard case DictationCommand.Scope.custom(let bundleID, let applicationName) = command.scope,
            applicationName == "Xcode",
            bundleID == "com.apple.dt.Xcode" else {
            XCTFail("it should have parsed out a command with an application-specific scope")
            return
        }

        guard case DictationCommand
            .Kind
            .pressKeyboardShortcut(let key, let modifierFlags) = command.kind,
            key == 15,
            modifierFlags == 1048576 else {
                XCTFail("it should have parsed out a press keyboard shortcut command")
                return
        }
    }
}


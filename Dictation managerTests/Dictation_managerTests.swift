import XCTest
@testable import Dictation_manager

class Dictation_managerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    func testItRepresentsACustomScope() {
        let customScope = DictationCommand.Scope.custom("com.apple.dt.Xcode", "Xcode")
        let customScopeRepresentation = customScope.propertyListRepresentation as? Dictionary<String, String>
        XCTAssert(customScopeRepresentation! == ["CustomAppName":"Xcode",
                                                 "CustomScope":"com.apple.dt.Xcode"])
    }
    
    func testItRepresentsASystemWideScope() {
        let systemwideScopeRepresentation = DictationCommand.Scope.systemwide.propertyListRepresentation as? Dictionary<String, String>
        XCTAssert(systemwideScopeRepresentation! == ["CustomScope":"com.apple.speech.SystemWideScope"])
    }
    
    func testItRepresentsKeyboardShortcuts() {
        let keyboardShortcutRepresentation = DictationCommand.Kind.pressKeyboardShortcut(100, 5000).propertyListRepresentation
        
        XCTAssert(keyboardShortcutRepresentation["CustomType"] as! String == "Shortcut")
        XCTAssert(keyboardShortcutRepresentation["CustomShortcutModifierFlags"] as! Int == 5000)
        XCTAssert(keyboardShortcutRepresentation["CustomShortcutKeyCode"] as! Int == 100)
    }
    
    func testItRepresentsPastingText() {
        let representation = DictationCommand.Kind.pasteText("some text to paste").propertyListRepresentation
        let pasteTextCommand = representation["CustomPasteText"] as! Array<Dictionary<String, Any>>
        
        let commandType = representation["CustomType"] as! String
        let dataType = pasteTextCommand.first!["CustomPasteBoardType"] as! String
        let data = pasteTextCommand.first!["CustomPasteBoardData"] as! Data
        let text = String(data: data, encoding: .utf8)
        
        XCTAssert(commandType == "PasteText")
        XCTAssert(dataType == "public.utf8-plain-text")
        XCTAssert(text == "some text to paste")
    }
    
    func testItRepresentsDictationCommands() {
        let date = Date()
        let command = DictationCommand(displayName: "Test Command",
                                       phoneticName: "test",
                                       lastModifiedDate: date,
                                       kind: .pressKeyboardShortcut(100, 5000),
                                       scope: .systemwide)
        
        
        let commandRepresentation = command.propertyListRepresentation
        
        
        let keys = commandRepresentation.keys.sorted(by: <)
        let modifiedDate = commandRepresentation["CustomModifyDate"] as? Date
        let customCommands = commandRepresentation["CustomCommands"] as! Dictionary<String, [String]>
        
        XCTAssert(keys == ["CustomCommands",
                           "CustomModifyDate",
                           "CustomScope",
                           "CustomShortcutKeyCode",
                           "CustomShortcutModifierFlags",
                           "CustomType"])
        XCTAssert(modifiedDate == date)
        XCTAssert(customCommands["en_US"]! == ["test"])
    }
}

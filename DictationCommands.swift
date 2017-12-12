//        case pasteData(Data)
//        case openUrl(URL)
//        case openFinderItems
//        case runWorkflow
//        case selectMenuBarItem(String)
import Foundation

typealias BundleID = String
typealias ApplicationName = String

protocol PropertyListRepresentation {
    var propertyListRepresentation: Dictionary<String, Any> { get }
}

struct DictationCommand: PropertyListRepresentation {
    var displayName: String
    let phoneticName: String
    let lastModifiedDate: Date
    let kind: Kind
    let scope: Scope
    
    var propertyListRepresentation: Dictionary<String, Any> {
        get {
            let scope = self.scope.propertyListRepresentation
            let kind = self.kind.propertyListRepresentation
            let command: [String : Any] = ["CustomCommands": ["en_US": [phoneticName]],
                                           "CustomModifyDate": lastModifiedDate]
            let keys: [String] = scope.keys + kind.keys + command.keys
            let values: [Any] = scope.values + kind.values + command.values
            
            return Dictionary.from(keys, and: values)
        }
    }
    
    enum Kind: PropertyListRepresentation {
        case pressKeyboardShortcut(Int, Int)
        case pasteText(String)
        var propertyListRepresentation: Dictionary<String, Any> {
            get {
                switch self {
                case .pressKeyboardShortcut(let shortcutKeyCode, let modifierKeyFlags):
                    return  ["CustomShortcutKeyCode": shortcutKeyCode,
                             "CustomShortcutModifierFlags": modifierKeyFlags,
                             "CustomType": "Shortcut"]
                case .pasteText(let text):
                    let entry = ["CustomPasteBoardData": text.data(using: .utf8)!,
                                 "CustomPasteBoardType": "public.utf8-plain-text"] as [String : Any]
                    return ["CustomPasteText": [entry],
                            "CustomType": "PasteText"]
                }
            }
        }
    }
    
    enum Scope: PropertyListRepresentation {
        case systemwide
        case custom(BundleID, ApplicationName)
        var propertyListRepresentation: Dictionary<String, Any> {
            get {
                switch self {
                case .custom(let bundleId, let applicationName):
                    return ["CustomAppName": applicationName,
                            "CustomScope": bundleId]
                default:
                    return ["CustomScope": "com.apple.speech.SystemWideScope"]
                }
            }
        }
    }
    
    struct Parser {
        
        static func parse(fileAt path: String) -> [DictationCommand] {
            let fileManager = FileManager()
            let fileContents = fileManager.contents(atPath: path)!
            
            let propertyList = try! PropertyListSerialization.propertyList(from: fileContents, options: .mutableContainersAndLeaves, format: nil) as! Dictionary<String, Any>
            let command = propertyList.first!.value as! Dictionary<String, Any>
            
            let dictationCommand = DictationCommand(displayName: "<#word#>",
                                                    phoneticName: name(for: command),
                                                    lastModifiedDate: date(for: command),
                                                    kind: kind(for: command),
                                                    scope: scope(for: command))
            return [dictationCommand]
        }
        
        private static func name(for command: Dictionary<String, Any>) -> String {
            let names = command["CustomCommands"] as! Dictionary<String, [String]>
            return names["en_US"]!.first!
        }
        
        private static func date(for command: Dictionary<String, Any>) -> Date {
            return command["CustomModifyDate"] as! Date
        }
        
        private static func scope(for command: Dictionary<String, Any>) -> Scope {
            let bundleID = command["CustomScope"] as! String
            let applicationName = command["CustomAppName"] as! String
            return .custom(bundleID, applicationName)
        }
        
        private static func kind(for command: Dictionary<String, Any>) -> Kind {
            let keyCode = command["CustomShortcutKeyCode"] as! Int
            let modifierFlags = command["CustomShortcutModifierFlags"] as! Int
            return .pressKeyboardShortcut(keyCode, modifierFlags)
        }
    }
}

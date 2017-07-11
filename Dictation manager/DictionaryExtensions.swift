extension Dictionary {
    var keys: [Key] {
        get {
            var keys = [Key]()
            for (key, _) in self {
                keys.append(key)
            }
            return keys
        }
    }
    
    var values: [Value] {
        get {
            var values = [Value]()
            for (_, value) in self {
                values.append(value)
            }
            return values
        }
    }
    
    static func from(_ keys: [Key], and values: [Value]) -> Dictionary {
        var dictionary = Dictionary<Key, Value>()
        for (index, key) in keys.enumerated() {
            dictionary[key] = values[index]
        }
        return dictionary
    }
}

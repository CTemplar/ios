//
//  Filter.swift
//  Networking


import Foundation

public struct Filter {
    // MARK: Properties
    public private (set) var id: Int?
    public private (set) var name: String?
    public private (set) var parameter: String?
    public private (set) var condition: String?
    public private (set) var filter_text: String?
    public private (set) var folder: String?
    public private (set) var move_to: Bool?
    public private (set) var mark_as_read: Bool?
    public private (set) var mark_as_starred: Bool?
    public private (set) var priority: Int?

    // MARK: Constructor
    public init() {}
    
    public init(dictionary: [String: Any]) {
        print(dictionary)
        self.id = dictionary["id"] as? Int
        self.priority = dictionary["priority_order"] as? Int
        self.name = dictionary["name"] as? String
        if let conditionArray = dictionary["conditions"] as? Array<[String:Any]> {
            if (conditionArray.count > 0) {
                self.condition = conditionArray[0]["condition"] as? String
                self.filter_text = conditionArray[0]["filter_text"] as? String
                self.parameter = conditionArray[0]["parameter"] as? String
            }
        }
        self.folder = dictionary["folder"] as? String
        self.move_to = dictionary["move_to"] as? Bool
        self.mark_as_read = dictionary["mark_as_read"] as? Bool
        self.mark_as_starred = dictionary["mark_as_starred"] as? Bool
    }
    
    
    public static func filterList(array: Array<Any>)-> Array<Any> {
        // MARK: - Parsing
        var objectsArray: [Filter] = []
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let messageResult = Filter(dictionary: objectDictionary)
                objectsArray.append(messageResult)
            }
        }
        return objectsArray
    }
    
    public mutating func setFilterData(name: String, parameter: String, condition: String, filterText: String, folder: String, moveTo: Bool, read:Bool, starred: Bool, id : Int) {
        self.name = name
        self.parameter = parameter
        self.condition = condition
        self.filter_text = filterText
        self.folder = folder
        self.move_to = moveTo
        self.mark_as_read = read
        self.mark_as_starred = starred
        self.id = id
    }
    
}

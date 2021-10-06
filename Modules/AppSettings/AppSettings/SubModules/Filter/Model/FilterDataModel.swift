//
//  FilterDataModel.swift




import UIKit
import Foundation
import Networking

enum FilterHeaders: Int {
    case name = 0
    case condition
    case select
    case conditionOrPattern
    case moveTo
    case folder
    case markAsRead
    case markAsStarred
}

struct ConditionValues {
  var serverValue = ""
  var frontValue = ""
}

struct FilterSectionHeader {
    static  let name = "FilterName"
    static let condition = "Condition"
    static let action = "Action"
}

struct FilterPlaceholderConstants {
    let name = "Filter name required"
    let condition = "Select condition"
    let select = "Select"
    let pattern = "Text or Pattern"
    let move = "Move To"
    let folder = "Select Folder"
    let read = "Mark as read"
    let starred = "Mark as starred"
    
}

class FilterModel: NSObject {
    var title: String = ""
    var isSelected = false
    var header: String = ""
    var placeholder: String = ""
    var type: FilterHeaders?
    var selectedValue: ConditionValues?
    var arrTypes = [ConditionValues]()
    var folderArrayTypes = [Folder]()
    
    func dropDownAvail()->Bool {
        switch (self.type?.rawValue) {
        case FilterHeaders.condition.rawValue:
            return false
        case FilterHeaders.select.rawValue:
            return false
        case FilterHeaders.folder.rawValue:
            return false
        default:
            return true
        }
    }
    
    func typeArray()-> Array<ConditionValues> {
        switch (self.type?.rawValue) {
        case FilterHeaders.condition.rawValue:
            return self.arrTypes
        case FilterHeaders.select.rawValue:
            return self.arrTypes
        case FilterHeaders.folder.rawValue:
            return self.arrTypes
        default:
            return []
        }
    }
    func getSelectedValue(serverValue:String)-> ConditionValues {
        for (_, conditionValue) in self.arrTypes.enumerated() {
            if(serverValue.lowercased() == conditionValue.serverValue.lowercased()) {
                return conditionValue
            }
        }
        return ConditionValues(serverValue: "", frontValue: "")
    }
    
    func typeArrayForFolder()-> Array<Folder> {
        switch (self.type?.rawValue) {
        case FilterHeaders.folder.rawValue:
            return self.folderArrayTypes
        default:
            return []
        }
    }
    
    func getselectedIndex()-> Int {
        for (index, industry) in self.arrTypes.enumerated() {
            if(self.title == industry.frontValue) {
                return index
            }
        }
        return 0
    }
    
    func saveTitle(index:Int, tag:Int) {
        
        if(self.arrTypes.count > index) {
            switch (tag) {
            case FilterHeaders.condition.rawValue:
                self.title = self.arrTypes[index].frontValue
            case FilterHeaders.select.rawValue:
                self.title = self.arrTypes[index].frontValue
            case FilterHeaders.folder.rawValue:
                self.title = self.folderArrayTypes[index].folderName ?? ""
            default:
                break
            }
        }
 
    }
    func saveValue(index:Int, tag:Int) {
        
        if(self.arrTypes.count > index) {
            switch (tag) {
            case FilterHeaders.condition.rawValue:
                self.selectedValue = self.arrTypes[index]
            case FilterHeaders.select.rawValue:
                self.selectedValue = self.arrTypes[index]
            default:
                break
            }
        }
 
    }
    func saveTitleForFolder(index:Int, tag:Int) {
        if(self.folderArrayTypes.count > index) {
            switch (tag) {
            case FilterHeaders.folder.rawValue:
                self.title = self.folderArrayTypes[index].folderName ?? ""
            default:
                break
            }
        }
    }
}

class FilterDataModel: NSObject {
    private (set) weak var parentController: AddFilterVC?
    var array = [Array<FilterModel>]()
    init(parentController: AddFilterVC) {
        super.init()
        self.parentController = parentController
        self.modelArray()
    }
    
    private func modelArray() {
        var nameArray = [FilterModel]()
        var commonArray = [FilterModel]()
        var actionArray = [FilterModel]()
        for index in 0...8  {
            let nameModel = FilterModel()
            let commonModel = FilterModel()
            let actionModel = FilterModel()
            let headers = FilterPlaceholderConstants()
           switch (index) {
            case FilterHeaders.name.rawValue:
                if (self.parentController?.isForEdit == true) {
                    nameModel.title = self.parentController?.filterModel?.name ?? ""
                }
                nameModel.placeholder = headers.name
                nameModel.type = FilterHeaders.name
                nameArray.append(nameModel)
            case FilterHeaders.condition.rawValue:
                commonModel.arrTypes = self.selectItems()
                if (self.parentController?.isForEdit == true) {
                    commonModel.selectedValue = commonModel.getSelectedValue(serverValue: self.parentController?.filterModel?.condition ?? "")
                    commonModel.title = commonModel.selectedValue?.frontValue ?? ""
                }
                commonModel.type = FilterHeaders.condition
                commonModel.placeholder = headers.condition
               
                commonArray.append(commonModel)
            case FilterHeaders.select.rawValue:
                commonModel.arrTypes = self.conditionItems()
                if (self.parentController?.isForEdit == true) {
                    commonModel.selectedValue = commonModel.getSelectedValue(serverValue: self.parentController?.filterModel?.parameter ?? "")
                    commonModel.title = commonModel.selectedValue?.frontValue ?? ""
                }
                commonModel.type = FilterHeaders.select
                commonModel.placeholder = headers.select
                commonArray.append(commonModel)
            case FilterHeaders.conditionOrPattern.rawValue:
                if (self.parentController?.isForEdit == true) {
                    commonModel.title = self.parentController?.filterModel?.filter_text ?? ""
                }
                commonModel.type = FilterHeaders.conditionOrPattern
                commonModel.placeholder = headers.pattern
                commonArray.append(commonModel)
            case FilterHeaders.moveTo.rawValue:
                if (self.parentController?.isForEdit == true) {
                    actionModel.isSelected = self.parentController?.filterModel?.move_to ?? false
                }
                actionModel.type = FilterHeaders.moveTo
                actionModel.placeholder = headers.move
                actionArray.append(actionModel)
            case FilterHeaders.folder.rawValue:
                if (self.parentController?.isForEdit == true) {
                    actionModel.title = self.parentController?.filterModel?.folder ?? ""
                    actionModel.isSelected = self.parentController?.filterModel?.move_to ?? false
                }
                actionModel.type = FilterHeaders.folder
                actionModel.placeholder = headers.folder
                actionModel.folderArrayTypes = self.foldersItems()
//                actionModel.folderArrayTypes.append(contentsOf: self.parentController?.folderModel ?? [])
                if let folderList = self.parentController?.folderModel {
                    for item in folderList {
                        actionModel.folderArrayTypes.append(item)
                    }
                }
                actionArray.append(actionModel)
            case FilterHeaders.markAsRead.rawValue:
                if (self.parentController?.isForEdit == true) {
                    actionModel.isSelected = self.parentController?.filterModel?.mark_as_read ?? false
                }
                actionModel.type = FilterHeaders.markAsRead
                actionModel.placeholder = headers.read
                actionArray.append(actionModel)
            case FilterHeaders.markAsStarred.rawValue:
                if (self.parentController?.isForEdit == true) {
                    actionModel.isSelected = self.parentController?.filterModel?.mark_as_starred ?? false
                }
                actionModel.type = FilterHeaders.markAsStarred
                actionModel.placeholder = headers.starred
                actionArray.append(actionModel)
            default:
                break
            }
           
        }
        self.array.append(nameArray)
        self.array.append(commonArray)
        self.array.append(actionArray)
    }
    
    private func conditionItems()-> Array<ConditionValues> {
        return [ConditionValues(serverValue: "subject", frontValue: "If the subject"),
                ConditionValues(serverValue: "sender", frontValue: "If the sender"),
                ConditionValues(serverValue: "receiver", frontValue: "If the receiver"),
                ConditionValues(serverValue: "header", frontValue: "If the header")]
    }
    
    private func selectItems()-> Array<ConditionValues> {
        return [ConditionValues(serverValue: "contain", frontValue: "Contain"),
                ConditionValues(serverValue: "not_contains", frontValue: "Does Not Contain"),
                ConditionValues(serverValue: "startswith", frontValue: "StartsWith"),
                ConditionValues(serverValue: "not_startswith", frontValue: "Does Not Contain StartsWith"),
                ConditionValues(serverValue: "endswith", frontValue: "EndsWith"),
                ConditionValues(serverValue: "not_endswith", frontValue: "Does Not EndsWith"),
                ConditionValues(serverValue: "exactly", frontValue: "Exactly"),
                ConditionValues(serverValue: "not_exactly", frontValue: "Does Not Exactly"),
                ConditionValues(serverValue: "match", frontValue: "Match"),
                ConditionValues(serverValue: "not_match", frontValue: "Does Not Match")]
    }
    private func foldersItems()-> Array<Folder> {
        
        return [Folder.folderFromName(name: "inbox"),Folder.folderFromName(name: "archive")
                ,Folder.folderFromName(name: "spam"),Folder.folderFromName(name: "trash")]
    }
}

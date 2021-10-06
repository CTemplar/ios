//
//  ComposerModel.swift
//  AppSettings
//


import UIKit
import Networking
enum ComposerHeader: Int {
    case color = 0
    case background
    case size
    case font
}

struct ComposerHeaderText {
    static let color = "Color"
    static let background = "Background Color"
    static let font = "Text Font"
    static let size = "Text size"
}
struct ComposerColor {
    static let none = "None"
    static let red = "Red"
    static let blue = "Blue"
    static let green = "Green"
    static let white = "White"
    static let black = "Black"
    static let pink = "Pink"
    static let grey = "Grey"
}

struct ComposerFont {
    static let mono = "Monospace"
    static let lato = "Lato"
    static let roboto = "Roboto"
    static let times = "Times-New-Roman"
}
struct ComposerSize {
    static let ten = "10px"
    static let twelve = "12px"
    static let forteen = "14px(Default)"
    static let sixteen = "16px"
    static let eighteen = "18px"
    static let twenty = "20px"
    static let twentyfour = "24px"
    static let thirtytwo = "32px"
}


class ComposerModel: NSObject {
    var title: String = ""
    var isSelected = false
    var header: String = ""
    var placeholder: String = ""
    var type: ComposerHeader?
    var selectedValue: ConditionValues?
    var arrTypes = [String]()
    
    func saveTitle(index:Int, tag:Int) {
        if(self.arrTypes.count > index) {
            switch (tag) {
            case ComposerHeader.color.rawValue:
                self.title = self.arrTypes[index]
            case ComposerHeader.background.rawValue:
                self.title = self.arrTypes[index]
            case ComposerHeader.size.rawValue:
                self.title = self.arrTypes[index]
            case ComposerHeader.font.rawValue:
                self.title = self.arrTypes[index]
            default:
                break
            }
        }
    }
}
class ComposerDataModel: NSObject {
    private (set) weak var parentController: ComposeVC?
    var array = [ComposerModel]()
    var user = UserMyself()
    init(parentController: ComposeVC, user: UserMyself) {
        super.init()
        self.parentController = parentController
        self.user = user
        self.modelArray()
    }
    
    private func modelArray() {
        for index in 0...3  {
            let composeModel = ComposerModel()
           switch (index) {
           case ComposerHeader.color.rawValue:
               composeModel.header = ComposerHeaderText.color
               composeModel.type = ComposerHeader.color
            composeModel.title = self.user.settings.color?.firstCapitalized ?? "None"
               composeModel.arrTypes = self.colorItems()
               self.array.append(composeModel)
            case ComposerHeader.background.rawValue:
                composeModel.header = ComposerHeaderText.background
                composeModel.type = ComposerHeader.background
                composeModel.title = self.user.settings.backgroundColor?.firstCapitalized ?? "None"
                composeModel.arrTypes = self.colorItems()
                self.array.append(composeModel)
            case ComposerHeader.size.rawValue:
                composeModel.header = ComposerHeaderText.size
                composeModel.type = ComposerHeader.size
                if (self.user.settings.size ?? 14 == 14) {
                    composeModel.title = "14px (Default)"
                }
                else {
                    composeModel.title = String(self.user.settings.size ?? 12) + "px"
                }
                composeModel.arrTypes = self.sizeItems()
                self.array.append(composeModel)
            case ComposerHeader.font.rawValue:
                composeModel.header = ComposerHeaderText.font
                composeModel.type = ComposerHeader.font
                composeModel.title = self.user.settings.plainTextFont?.firstCapitalized ?? "Monospace"
                composeModel.arrTypes = self.fontItems()
                self.array.append(composeModel)
           default:
                break
            }
        }
    }

    private func colorItems()-> Array<String> {
        return [ComposerColor.none,
                ComposerColor.red,
                ComposerColor.blue,
                ComposerColor.green,
                ComposerColor.white,
                ComposerColor.black,
                ComposerColor.pink,
                ComposerColor.grey]
    }
    private func sizeItems()-> Array<String> {
        return [ComposerSize.ten,
                ComposerSize.twelve,
                ComposerSize.forteen,
                ComposerSize.sixteen,
                ComposerSize.eighteen,
                ComposerSize.twenty,
                ComposerSize.twentyfour,
                ComposerSize.thirtytwo]
    }
    private func fontItems()-> Array<String> {
        return [ComposerFont.mono,
                ComposerFont.lato,
                ComposerFont.roboto,
                ComposerFont.times]
    }
}


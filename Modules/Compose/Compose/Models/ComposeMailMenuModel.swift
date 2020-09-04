import Utility
import UIKit
import Combine

public enum ComposeMailMenu {
    case attachment
    case mailEncryption
    case selfDesctructionTimer
    case delayedDelivery
    case deadManTimer
}

public final class ComposeMailMenuModel: Modelable {
    // MARK: Properties
    @Published private (set) var selectedMenus: [ComposeMailMenu] = []
    
    // MARK: - Constructor
    public init(selectedMenus: [ComposeMailMenu] = []) {
        self.selectedMenus = selectedMenus
    }
    
    // MARK: - Update
    public func update(menu: ComposeMailMenu, shouldAdd: Bool) {
        var menus = selectedMenus
        if let index = menus.firstIndex(of: menu) {
            if !shouldAdd {
                menus.remove(at: index)
            }
        } else {
            menus.append(menu)
        }
        selectedMenus = menus
    }
}

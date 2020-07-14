import Foundation

public final class SharedInboxState {
    public static let shared = SharedInboxState()
    public private (set) var selectedMenu: MenuConfigurable?
    private (set) var selectedPreferences: Menu.Preferences?
    private (set) var selectedCustomFolderIndexPath: IndexPath?
    private (set) var appliedFilters: [InboxFilter] = []
    
    // MARK: Constructor
    private init() {
        self.selectedMenu = Menu.inbox
    }
    
    // MARK: - Update
    func update(menu: MenuConfigurable?) {
        self.selectedMenu = menu
    }
    
    func update(preferences: Menu.Preferences?) {
        self.selectedPreferences = preferences
    }
    
    func update(customFolderIndexPath: IndexPath?) {
        self.selectedCustomFolderIndexPath = customFolderIndexPath
    }
    
    func update(appliedFilters: [InboxFilter]) {
        self.appliedFilters = appliedFilters
    }
}

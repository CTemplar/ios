import Foundation

final class SharedInboxState {
    static let shared = SharedInboxState()
    private (set) var selectedMenu = Menu.inbox
    private (set) var selectedPreferences: Menu.Preferences?
    private (set) var selectedCustomFolderIndexPath: IndexPath?
    private (set) var appliedFilters: [InboxFilter] = []
    
    // MARK: Constructor
    private init() {
    }
    
    // MARK: - Update
    func update(menu: Menu) {
        self.selectedMenu = menu
    }
    
    func update(preferences: Menu.Preferences) {
        self.selectedPreferences = preferences
    }
    
    func update(customFolderIndexPath: IndexPath) {
        self.selectedCustomFolderIndexPath = customFolderIndexPath
    }
    
    func update(appliedFilters: [InboxFilter]) {
        self.appliedFilters = appliedFilters
    }
}

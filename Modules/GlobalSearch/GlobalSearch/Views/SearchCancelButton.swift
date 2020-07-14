import SwiftUI

struct SearchCancelButton: View {
    // MARK: Properties
    @Binding
    var searchTerm: String
    
    @Binding
    var showCancelButton: Bool
    
    var cancelButtonTitle: String
    
    // MARK: Content View
    var body: some View {
        Button(cancelButtonTitle) {
            UIApplication.shared.endEditing(true) // this must be placed before the other commands here
            self.searchTerm = ""
            self.showCancelButton = false
        }
        .foregroundColor(Color(.orange))
    }
}

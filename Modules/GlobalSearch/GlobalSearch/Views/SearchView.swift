//
//  SearchView.swift
//  GlobalSearch
//


import SwiftUI

struct SearchView: View {
    // MARK: Properties
    @Binding
    var searchTerm: String
    
    @Binding
    var showCancelButton: Bool
    
    var onCommit: () -> Void = {}
    
    // MARK: - Content View
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .padding(.leading, 2.0)
            
            TextField("Search", text: $searchTerm,
                      onEditingChanged: { (isEditing) in
                self.showCancelButton = true
            }, onCommit: {
                self.onCommit()
            }).foregroundColor(.primary)
            
            Button(action: {
                self.searchTerm = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .opacity(searchTerm == "" ? 0 : 1)
            }
        }.padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
    }
}

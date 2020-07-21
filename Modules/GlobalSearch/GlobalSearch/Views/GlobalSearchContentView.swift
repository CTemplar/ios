//
//  GlobalSearchContentView.swift
//  GlobalSearch
//

import SwiftUI
import UIKit

struct GlobalSearchContentView: View {
    // MARK: Properties
    let names = ["Raju", "Ghanshyam", "Baburao Ganpatrao Apte", "Anuradha", "Kabira", "Chaman Jhinga", "Devi Prasad", "Khadak Singh"]
    @State
    private var searchTerm = ""
    
    @State
    private var showCancelButton = false
    
    @State
    private var showEmptyState = false
    
    private var results: [String] {
        let items = names.filter{$0.hasPrefix(searchTerm) || searchTerm.isEmpty == true}
        showEmptyState = items.isEmpty
        return items
    }
    
    init() {
        if #available(iOS 14.0, *) {
            // iOS 14 doesn't have extra separators below the list by default.
        } else {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    // Show Search bar
                    SearchView(searchTerm: $searchTerm,
                               showCancelButton: $showCancelButton,
                               onCommit: search
                    )
                    
                    // For showing cancel button on search bar
                    if showCancelButton {
                        SearchCancelButton(searchTerm: $searchTerm,
                                           showCancelButton: $showCancelButton,
                                           cancelButtonTitle: "Cancel"
                        )
                    }
                    
                }.padding(.horizontal)
                    .navigationBarHidden(showCancelButton)
                    .animation(.easeInOut)
                
                ZStack {
                    List {
                        // Filtered list of names
                        ForEach(results, id:\.self) { (searchText) in
                            SearchRowView(sender: searchText)
                        }
                    }
                    .navigationBarTitle(Text("Search"), displayMode: .large)
                    .resignKeyboardOnDragGesture()
                    
                    VStack {
                        if showEmptyState {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60.0, height: 60.0, alignment: .center)
                                .foregroundColor(.orange)
                            
                            Text("Search Results not found")
                        }
                    }
                }
            }
        }
    }
    
    private func search() {
        // viewModel.search(forQuery: searchTerm)
    }
}

#if DEBUG
struct GlobalSearchContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GlobalSearchContentView()
                .colorScheme(.dark)
                .background(Color.black)
        }
    }
}
#endif

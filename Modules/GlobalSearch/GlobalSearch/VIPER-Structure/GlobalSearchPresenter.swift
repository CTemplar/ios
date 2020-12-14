import Foundation
import Utility
import UIKit
import Networking
import Combine

final class GlobalSearchPresenter: NSObject {
    // MARK: Properties
    private (set) weak var searchViewController: GlobalSearchViewController?
    
    private (set) var interactor: GlobalSearchInteractor
    
    private var router: GlobalSearchRouter
    
    var isViewControllerAppearing = false
    
    @Published private var searchText: String = ""
    
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: Properties
    private (set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    
    private var searchActive = false
    
    private var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchActive && isSearchBarEmpty == false
    }
    
    var searchQuery: String {
        return searchController.searchBar.text ?? ""
    }
    
    // MARK: - Constructor
    init(searchController: GlobalSearchViewController, interactor: GlobalSearchInteractor, router: GlobalSearchRouter) {
        self.searchViewController = searchController
        self.interactor = interactor
        self.router = router
        super.init()
        
        self.setupObserver()
    }
    
    // MARK: - Setup
    private func setupObserver() {
        $searchText
            .debounce(for: .milliseconds(800), scheduler: DispatchQueue.main) // debounces the string publisher, such that it delays the process of sending request to remote server.
            .removeDuplicates()
            .map({ (string) -> String? in
                return string
            }) // prevents sending numerous requests and sends nil if the count of the characters is less than 1.
            .compactMap{ $0 } // removes the nil values so the search string does not get passed down to the publisher chain
            .sink { (_) in
                //
            } receiveValue: { [weak self] (searchField) in
                if self?.isViewControllerAppearing == false {
                    self?.isViewControllerAppearing = true
                    return
                }
                self?.performSearch(by: searchField)
            }.store(in: &subscription)
    }
    
    func setupUI() {
        searchViewController?.noResultsLabel.text = Strings.Search.noResults.localized
        searchViewController?.extendedLayoutIncludesOpaqueBars = true
        searchViewController?.edgesForExtendedLayout = []
        searchViewController?.emptyStateStackView.isHidden = true
        setupSearchController()
        updateNavigationColors()
    }
    
    func updateNavigationColors() {
        searchViewController?.navigationController?.prefersLargeTitle = true
        searchViewController?.navigationItem.title = Strings.Search.search.localized
        searchViewController?.navigationController?.updateTintColor()
        searchController.searchBar.tintColor = AppStyle.Colors.loaderColor.color
    }
    
    private func setupSearchController() {
        searchViewController?.definesPresentationContext = true
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Strings.Search.search.localized
        searchViewController?.navigationItem.searchController = searchController
        searchViewController?.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func tweakSearchController() {
        if searchController.isActive == false {
            searchController.becomeFirstResponder()
            searchController.searchBar.becomeFirstResponder()
            searchController.isActive = true
        }
    }
    
    func updateEmptyState(shouldShow: Bool) {
        searchViewController?.emptyStateStackView.isHidden = shouldShow ? false : true
    }
    
    func turnOffLoading() {
        searchController.searchBar.isLoading = false
    }
    
    // MARK: - Interactor Updates
    func update(folders: [Folder]) {
        searchViewController?.dataSource?.update(folders: folders)
    }
    
    func showAlert(withTitle title: String, message: String) {
        searchViewController?.showAlert(with: title, message: message, buttonTitle: Strings.Button.okButton.localized)
    }
    
    // MARK: - Datasource Updates
    func onTap(message: EmailMessage, user: UserMyself) {
        router.showInboxDetail(forMessage: message, user: user)
    }
    
    // MARK: - API Handlers
    func getAllFolders() {
        interactor.getFolders()
    }
}

// MARK: - UISearchResultsUpdating
extension GlobalSearchPresenter: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
    }
    
    @objc
    private func performSearch(by query: String) {
        guard query.trimmingCharacters(in: .whitespaces).isEmpty == false else {
            DPrint("nothing to search")
            interactor.update(offset: 0)
            interactor.update(totalItems: 0)
            searchViewController?.dataSource?.updateDatasource(by: [])
            return
        }
        
        if searchController.isActive {
            searchController.searchBar.isLoading = true
            interactor.searchMessages(withQuery: query)
        }
    }
}
// MARK: - Searchbar Delegates
extension GlobalSearchPresenter: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        interactor.update(offset: 0)
        interactor.update(totalItems: 0)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
}

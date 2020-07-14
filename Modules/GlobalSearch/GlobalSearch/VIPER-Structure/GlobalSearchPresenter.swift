import Foundation
import Utility
import UIKit
import Networking

final class GlobalSearchPresenter: NSObject {
    // MARK: Properties
    private (set) weak var searchViewController: GlobalSearchViewController?
    private (set) var interactor: GlobalSearchInteractor
    private var router: GlobalSearchRouter
    var isViewControllerAppearing = false
    var searchQuery: String {
        return searchController.searchBar.text ?? ""
    }
    
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
    
    // MARK: - Constructor
    init(searchController: GlobalSearchViewController, interactor: GlobalSearchInteractor, router: GlobalSearchRouter) {
        self.searchViewController = searchController
        self.interactor = interactor
        self.router = router
        super.init()
    }
    
    // MARK: - UI Setup
    func setupUI() {
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
            searchController.isActive = true
            searchController.becomeFirstResponder()
            delay(0.5) { [weak self] in
                self?.searchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
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
        if !isViewControllerAppearing {
            isViewControllerAppearing = true
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload(_:)),
                                               object: searchController.searchBar)
        perform(#selector(reload(_:)), with: searchController.searchBar, afterDelay: 0.75)
    }
    
    @objc
    private func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces).isEmpty == false else {
            print("nothing to search")
            interactor.update(offset: 0)
            interactor.update(totalItems: 0)
            searchViewController?.dataSource?.updateDatasource(by: [])
            return
        }
        
        if searchController.isActive {
            searchBar.isLoading = true
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

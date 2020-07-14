import Foundation
import Utility
import Networking

final class GlobalSearchInteractor: NSObject {
    // MARK: Properties
    private weak var presenter: GlobalSearchPresenter?
    private let apiService = NetworkManager.shared.apiService
    private (set) var offset = 0
    private (set) var totalItems = 0
    private (set) var isFetchInProgress = false
    
    // MARK: - Setup
    func setup(presenter: GlobalSearchPresenter?) {
        self.presenter = presenter
    }
    
    // MARK: - Handle Response
    private func updateDataSource(with messages: EmailMessagesList,
                                  currentSearchQuery: String) {
        if offset == 0 {
            presenter?.searchViewController?.dataSource?.updateDatasource(by: [])
        }

        if let emails = messages.messagesList {
            let existingMessages = presenter?.searchViewController?.dataSource?.messages ?? []
            let combinedMessages = existingMessages + emails
            presenter?.searchViewController?.dataSource?.updateDatasource(by: combinedMessages)
        }
    }
    
    func update(offset: Int) {
        self.offset = offset
    }
    
    func update(totalItems: Int) {
        self.totalItems = totalItems
    }

    // MARK: - API Calls
    func getFolders() {
        Loader.start()
        apiService.customFoldersList(limit: 200, offset: 0) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch(result) {
                case .success(let value):
                    if let folderList = value as? FolderList {
                        self?.presenter?.update(folders: folderList.foldersList ?? [])
                    } else {
                        self?.presenter?.update(folders: [])
                    }
                case .failure(let error):
                    print("error:", error)
                    self?.presenter?.showAlert(withTitle: Strings.AppError.foldersError.localized,
                                               message: error.localizedDescription)
                }
            }
        }
    }
    
    func searchMessages(withQuery searchQuery: String) {
        if offset >= totalItems, offset > 0 {
            presenter?.turnOffLoading()
            return
        }
        
        if isFetchInProgress {
            presenter?.turnOffLoading()
            return
        }
        
        isFetchInProgress = true
        
        apiService.searchMessageList(withQuery: searchQuery, offset: offset) { [weak self] (result) in
            guard let safeSelf = self else {
                return
            }
            
            safeSelf.isFetchInProgress = false
            
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    if let emailMessages = value as? EmailMessagesList {
                        safeSelf.totalItems = emailMessages.totalCount ?? 0
                        let newOffset = safeSelf.offset + GeneralConstant.OffsetValue.pageLimit.rawValue
                        safeSelf.update(offset: newOffset)
                        safeSelf.updateDataSource(with: emailMessages, currentSearchQuery: searchQuery)
                    } else {
                        safeSelf.presenter?.showAlert(withTitle: Strings.AppError.messagesError.localized,
                                                      message: Strings.AppError.unknownError.localized)
                    }
                case .failure(let error):
                    DPrint("error:", error)
                    safeSelf.presenter?.showAlert(withTitle: Strings.AppError.messagesError.localized,
                                                  message: error.localizedDescription)
                }
            }
        }
    }
}

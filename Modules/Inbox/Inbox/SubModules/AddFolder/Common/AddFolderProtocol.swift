import Foundation
import Networking

protocol AddFolderDelegate: AnyObject {
    func didAddFolder(_ folder: Folder)
}

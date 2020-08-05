import UIKit

enum RememberCredentialState {
    case remember
    case doNotRemember
    
    func stateImage() -> UIImage? {
        return self == .remember ? #imageLiteral(resourceName: "checked") : nil
    }
    
    static func getState(from selectionState: Bool) -> RememberCredentialState {
        return selectionState ? .remember : .doNotRemember
    }
}

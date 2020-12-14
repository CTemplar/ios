import UIKit

enum RememberCredentialState {
    case remember
    case doNotRemember
    
    func stateImage() -> UIImage? {
        return self == .remember ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
    }
    
    static func getState(from selectionState: Bool) -> RememberCredentialState {
        return selectionState ? .remember : .doNotRemember
    }
}

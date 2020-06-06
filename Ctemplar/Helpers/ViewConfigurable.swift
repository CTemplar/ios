import UIKit

protocol Configuration {}

protocol ViewConfigurable where Self: UIView {
    associatedtype AdditionalConfig: Configuration
    init(with configs: [AdditionalConfig])
}

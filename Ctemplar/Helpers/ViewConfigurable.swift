import UIKit

protocol Configuration {}

protocol Configurable {
    associatedtype AdditionalConfig: Configuration
    init(with configs: [AdditionalConfig])
}

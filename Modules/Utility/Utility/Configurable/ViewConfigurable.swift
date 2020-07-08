import UIKit

public protocol Configuration {}

public protocol Configurable {
    associatedtype AdditionalConfig: Configuration
    init(with configs: [AdditionalConfig])
}

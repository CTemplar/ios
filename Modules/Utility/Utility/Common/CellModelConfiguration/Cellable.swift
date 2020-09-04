import UIKit

public protocol Cellable where Self: UIView {
    func configure(with model: Modelable)
}

public protocol Bindable where Self: UIViewController {
    associatedtype ModelType: Modelable
    func configure(with model: ModelType)
}

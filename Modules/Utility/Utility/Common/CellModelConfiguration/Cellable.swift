import UIKit

public protocol Cellable where Self: UIView {
    associatedtype ModelType: Modelable
    func configure(with model: ModelType)
}

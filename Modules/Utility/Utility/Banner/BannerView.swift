import UIKit
import QuickLayout

final class BannerView: UIView, Configurable {
    // MARK: Properties
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    private var verticalConstrainsts: QLAxisConstraints!

    public var verticalOffset: CGFloat = 5 {
        didSet {
            verticalConstrainsts.first.constant = verticalOffset
            verticalConstrainsts.second.constant = -verticalOffset
            layoutIfNeeded()
        }
    }

    private var onButtonTap: (() -> ())?
    typealias AdditionalConfig = BannerViewConfig
    
    enum BannerViewConfig: Configuration {
        case titleFont(UIFont)
        case buttonFont(UIFont)
        case titleColor(UIColor)
        case buttonTextColor(UIColor)
        case titleText(String)
        case buttonTitle(String)
        case showButton(Bool)
        case action(() -> ())
    }
    
    // MARK: - Initializer
    init(with configs: [BannerViewConfig]) {
        super.init(frame: UIScreen.main.bounds)
        var labelText = ""
        var buttonText = ""
        var titleFont = AppStyle.CustomFontStyle.Bold.font(withSize: 16.0)
        var titleColor = UIColor(named: "bottomBarBackgroundColor")
        var buttonFont = AppStyle.CustomFontStyle.Regular.font(withSize: 20.0)
        var buttonTitleColor = AppStyle.StringColor.blue.color
        
        for config in configs {
            switch config {
            case .titleFont(let font):
                titleFont = font
            case .titleColor(let color):
                titleColor = color
            case .buttonFont(let font):
                buttonFont = font
            case .buttonTextColor(let color):
                buttonTitleColor = color
            case .titleText(let title):
                labelText = title
            case .buttonTitle(let title):
                buttonText = title
            case .action(let completion):
                onButtonTap = completion
            case .showButton(let shouldShow):
                closeButton.isHidden = shouldShow ? false : true
            }
        }
        setupTitleLabel(withText: labelText, font: titleFont, color: titleColor)
        setupButton(withText: buttonText, font: buttonFont, color: buttonTitleColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupTitleLabel(withText text: String,
                                 font: UIFont?,
                                 color: UIColor?) {
        addSubview(titleLabel)
        titleLabel.text = text
        titleLabel.textColor = color
        titleLabel.font = font
        verticalConstrainsts = titleLabel.layoutToSuperview(axis: .vertically, offset: 20.0, priority: .must)
        titleLabel.layout(.leading, to: self, offset: 16)
    }
    
    private func setupButton(withText text: String,
                             font: UIFont?,
                             color: UIColor?) {
        addSubview(closeButton)
        closeButton.setTitle(text, for: .normal)
        closeButton.setTitleColor(color, for: .normal)
        closeButton.titleLabel?.font = font
        closeButton.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        
        closeButton.layoutToSuperview(axis: .vertically)
        closeButton.layoutToSuperview(.trailing, relation: .equal, offset: -16.0, priority: .must)
    }
    
    // MARK: - Action
    @objc
    private func onTap(_ sender: UIButton) {
        onButtonTap?()
    }
}

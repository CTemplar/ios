import Foundation
import UIKit
import Utility
import Combine
import Networking

public final class ComposeMailMenuCell: UITableViewCell, Cellable {
    // MARK: Properties
    private let attachmentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "Attach"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "AttachAplied"), for: .selected)
        return button
    }()
    
    private let mailEncryptionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "encrypt"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "encryptAplied"), for: .selected)
        return button
    }()
    
    private let trashButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "selfDestructed"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "selfDestructedAplied"), for: .selected)
        return button
    }()
    
    private let timerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "delayedDelivery"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "delayedDeliveryAplied"), for: .selected)
        return button
    }()
    
    private let deadManTimerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "deadMan"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "deadManAplied"), for: .selected)
        return button
    }()
    
    var model: ComposeMailMenuModel!
    
    var onTapAttachment: ((UIButton, Bool) -> Void)?
    
    var onTapMailEncryption: ((Bool) -> Void)?
    
    var onTapDestruction: ((Bool) -> Void)?
    
    var onTapDelayDelivery: ((Bool) -> Void)?
    
    var onTapDeadManTimer: ((Bool) -> Void)?
    
    @Published private var selectAttachment: Bool = false
    
    @Published private var selectEncryption: Bool = false

    @Published private var selectDesctruction: Bool = false

    @Published private var selectDelayedDelivery: Bool = false
    
    @Published private var selectDeadmanTimer: Bool = false
     var user = UserMyself()
    private var anyCancellables = Set<AnyCancellable>()
    
    // MARK: - Actions
    @objc
    private func onTapAttachment(_ sender: UIButton) {
        onTapAttachment?(sender, model.selectedMenus.contains(.attachment))
    }
    
    @objc
    private func onTapMailEncryption(_ sender: UIButton) {
 
            onTapMailEncryption?(model.selectedMenus.contains(.mailEncryption))
    }
    
    @objc
    private func onTapDestruction(_ sender: UIButton) {
      
            onTapDestruction?(model.selectedMenus.contains(.selfDesctructionTimer))
    }
    
    @objc
    private func onTapDelayDelivery(_ sender: UIButton) {
        
            onTapDelayDelivery?(model.selectedMenus.contains(.delayedDelivery))
    }
    
    @objc
    private func onTapDeadManTimer(_ sender: UIButton) {
    
            onTapDeadManTimer?(model.selectedMenus.contains(.deadManTimer))
    }
    
    // MARK: - Constructor
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        buildLayout()
    }
    
    deinit {
        anyCancellables.forEach({ $0.cancel() })
        anyCancellables.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupObservers() {
        model
            .$selectedMenus
            .receive(on: RunLoop.main)
            .sink { [weak self] (menus) in
                self?.updateMenu(from: menus)
        }
        .store(in: &anyCancellables)
        
        anyCancellables = [
            $selectAttachment
                .receive(on: DispatchQueue.main)
                .assign(to: \.isSelected, on: attachmentButton),
            
            $selectEncryption
                .receive(on: DispatchQueue.main)
                .assign(to: \.isSelected, on: mailEncryptionButton),
            
            $selectDesctruction
                .receive(on: DispatchQueue.main)
                .assign(to: \.isSelected, on: trashButton),
            
            $selectDelayedDelivery
                .receive(on: DispatchQueue.main)
                .assign(to: \.isSelected, on: timerButton),
            
            $selectDeadmanTimer
                .receive(on: DispatchQueue.main)
                .assign(to: \.isSelected, on: deadManTimerButton)
        ]
    }
    
    private func buildLayout() {
        backgroundColor = .tertiarySystemGroupedBackground
        
        attachmentButton.addTarget(self, action: #selector(onTapAttachment(_:)), for: .touchUpInside)
        mailEncryptionButton.addTarget(self, action: #selector(onTapMailEncryption(_:)), for: .touchUpInside)
        timerButton.addTarget(self, action: #selector(onTapDelayDelivery(_:)), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(onTapDestruction(_:)), for: .touchUpInside)
        deadManTimerButton.addTarget(self, action: #selector(onTapDeadManTimer(_:)), for: .touchUpInside)

        let horizontalStackView = UIStackView(arrangedSubviews:
            [
                attachmentButton,
                mailEncryptionButton,
                trashButton,
                timerButton,
                deadManTimerButton
            ]
        )
        
        horizontalStackView.alignment = .center
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillProportionally

        contentView.addSubview(horizontalStackView)
        
        horizontalStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        }
    }

    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? ComposeMailMenuModel else {
            fatalError("Couldn't typecast ComposeMailMenuModel")
        }
        
        self.model = model
        setupObservers()
    }
    
    func setButtonState(isEnable:Bool) {
        if (isEnable == false) {
            self.deadManTimerButton.isEnabled = false
            self.mailEncryptionButton.isEnabled = false
            self.trashButton.isEnabled = false
            self.timerButton.isEnabled = false
        }
        
    }
    
    private func updateMenu(from selectedMenus: [ComposeMailMenu]) {
        selectAttachment = false
        selectDeadmanTimer = false
        selectDelayedDelivery = false
        selectEncryption = false
        selectDesctruction = false
        
        for menu in selectedMenus {
            switch menu {
            case .attachment:
                selectAttachment = true
            case .deadManTimer:
                selectDeadmanTimer = true
            case .delayedDelivery:
                selectDelayedDelivery = true
            case .mailEncryption:
                selectEncryption = false
            case .selfDesctructionTimer:
                selectDesctruction = true
            }
        }
    }    
}

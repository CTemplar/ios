import UIKit
import Utility
import SnapKit

public final class InboxViewerMailSenderHeaderView: UIView, Cellable {
    
    // MARK: Properties
    public typealias ModelType = InboxViewerMailSenderHeader

    private var model: InboxViewerMailSenderHeader?
    
    private var collapsedState: InboxHeaderState = .collapsed
    
    var onTapViewDetails: ((Bool) -> Void)?
        
    private let fromNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private let toNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = k_emailToColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = k_emailToColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)
        label.textAlignment = .left
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UITraitCollection.current.userInterfaceStyle == .dark ? .link : k_blueColor, for: .normal)
        button.addTarget(self, action: #selector(onTapToggle), for: .touchUpInside)
        button.isSelected = false
        return button
    }()
    
    private let mailDetailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemGroupedBackground
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = k_lightGrayTextColor
        return view
    }()
    
    private lazy var timerLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textColor = .white
        label.backgroundColor = k_orangeColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 9.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var deleteLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textColor = .white
        label.backgroundColor = k_redColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 9.0)
        label.textAlignment = .center
        return label
    }()
    
    var onTapHeader: ((InboxHeaderState) -> Void)?

    // MARK: - Constructor
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        removeBorder(toSide: .Bottom)
        addBottomBorderWithColor(color: k_borderColor, width: 1.0)
    }
    
    // MARK: - Setup UI
    private func buildLayout() {
        backgroundColor = k_mailSenderCellBackgroundColor
        
        [
            toggleButton,
            mailDetailContainerView,
            borderView
        ].forEach({
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        toggleButton.setAttributedTitle(
            getAttributedText(
                from: Strings.InboxViewer.viewDetails.localized
            ),
            for: .normal
        )
        
        toggleButton.setAttributedTitle(
            getAttributedText(
                from: Strings.InboxViewer.hideDetails.localized
            ),
            for: .selected
        )

        toggleButton.isHidden = true
        
        // Layout Constraint
        toggleButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        toggleButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
                
        let leadingStackView = UIStackView(arrangedSubviews: [fromNameLabel, toNameLabel, dateLabel])
        leadingStackView.distribution = .fillProportionally
        leadingStackView.axis = .vertical
        leadingStackView.alignment = .leading
        leadingStackView.spacing = 4.0

        addSubview(leadingStackView)
        
        mailDetailContainerView.snp.makeConstraints { (make) in
            make.height.equalTo(0.0)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        leadingStackView.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.leading.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(8.0)
            make.trailing.equalTo(safeSelf.toggleButton.snp.leading).inset(-8.0)
            make.bottom.equalTo(safeSelf.mailDetailContainerView.snp.top).inset(-8.0)
        }
                
        toggleButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-8.0)
            make.bottom.equalTo(leadingStackView.snp.bottom).inset(-4.0)
        }
    }
    
    private func getCommonEmailIdLabel(with value: String) -> UILabel {
        let label = UILabel()
        label.text = value
        label.textColor = k_emailToColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)
        return label
    }
    
    private func layoutDetailStackView(_ stackView: UIStackView) {
        mailDetailContainerView.addSubview(stackView)

        stackView.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.edges.equalTo(safeSelf.mailDetailContainerView)
                .inset(UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 4.0))
        }
        
        mailDetailContainerView.snp.remakeConstraints { (make) in
            make.height.equalTo(stackView.snp.height).offset(16.0)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func removeDetailStackView() {
        mailDetailContainerView.subviews.forEach({
            $0.removeFromSuperview()
        })
        
        mailDetailContainerView.snp.makeConstraints { (make) in
            make.height.equalTo(0.0)
        }
    }
    
    private func layoutTimerLabel(withTimer timer: NSAttributedString,
                                  deleteText: NSAttributedString,
                                  timerBCColor: UIColor,
                                  deleteBCColor: UIColor) {
        var arrangedSubView: [UIView] = []
        
        if !deleteText.string.isEmpty {
            deleteLabel.attributedText = deleteText
            deleteLabel.backgroundColor = deleteBCColor
            addSubview(deleteLabel)
            arrangedSubView.append(deleteLabel)
        }
        
        if !timer.string.isEmpty {
            timerLabel.attributedText = timer
            timerLabel.backgroundColor = timerBCColor
            addSubview(timerLabel)
            arrangedSubView.append(timerLabel)
        }
        
        let trailingStackView = UIStackView(arrangedSubviews: arrangedSubView)
        trailingStackView.distribution = .fillProportionally
        trailingStackView.axis = .horizontal
        trailingStackView.alignment = .trailing
        trailingStackView.clipsToBounds = true
        addSubview(trailingStackView)
        
        trailingStackView.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.top.equalToSuperview().offset(8.0)
            make.trailing.equalTo(safeSelf.toggleButton.snp.trailing)
        }
    }
    
    private func getAttributedText(from text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        let attributedString = NSMutableAttributedString(string: text, attributes:
            [
                .font: AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!,
                .foregroundColor: UITraitCollection.current.userInterfaceStyle == .dark ? .link : k_blueColor,
                .kern: 0.0,
                .paragraphStyle: paragraph
            ]
        )
        
        _ = attributedString.setUnderline(textToFind: text)
        return attributedString
    }
    
    // MARK: - Actions
    @objc
    func onTapToggle() {
        toggleButton.isSelected = !toggleButton.isSelected
        
        if toggleButton.isSelected {
            if model?.detailMailIdsWithAttribute.isEmpty == false {
                var detailMailIdLabels: [UILabel] = []
                
                for senderType in model?.detailMailIdsWithAttribute ?? [] {
                    var malAddress = ""
                    switch senderType {
                    case .to(let mailId):
                        malAddress = mailId
                    case .from(let mailId):
                        malAddress = mailId
                    case .cc(let mailId):
                        malAddress = mailId
                    case .bcc(let mailId):
                        malAddress = mailId
                    }
                    
                    let label = getCommonEmailIdLabel(with: malAddress)
                    detailMailIdLabels.append(label)
                }
                
                if !detailMailIdLabels.isEmpty {
                    let detailMailStackView = UIStackView(arrangedSubviews: detailMailIdLabels)
                    detailMailStackView.distribution = .fillProportionally
                    detailMailStackView.axis = .vertical
                    detailMailStackView.alignment = .leading
                    detailMailStackView.spacing = 4.0
                    layoutDetailStackView(detailMailStackView)
                }
            }
        } else {
            removeDetailStackView()
        }
        
        onTapViewDetails?(toggleButton.isSelected)
    }
    
    @objc
    private func onTapHeader(_ sender: Any) {
        collapsedState = collapsedState == .collapsed ? .expanded : .collapsed
        onTapHeader?(collapsedState)
    }
    
    // MARK: - Configuration
    public func configure(with model: InboxViewerMailSenderHeader) {
        self.model = model
        
        fromNameLabel.text = model.senderName
        toNameLabel.text = model.receiverEmailId
        dateLabel.text = model.mailSentDate
        toggleButton.isHidden = model.detailMailIdsWithAttribute.isEmpty
        
        collapsedState = model.state
        
        if let property = model.emailProperty {
            layoutTimerLabel(withTimer: property.timerText,
                             deleteText: property.deleteText,
                             timerBCColor: property.timerBackgroundColor,
                             deleteBCColor: property.deleteBackgroundColor)
        }

        if model.isTappable == true {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapHeader(_:)))
            addGestureRecognizer(tapGesture)
        }
        
        layoutIfNeeded()
    }
}

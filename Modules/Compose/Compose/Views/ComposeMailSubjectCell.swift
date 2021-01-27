import Foundation
import UIKit
import Utility
import SnapKit
import Combine

public final class ComposeMailSubjectCell: UITableViewCell, Cellable {
    // MARK: Properties
    private var model: ComposeMailSubjectModel!
    
    private let subjectTextField: UITextField = {
        let textfield = UITextField()
        textfield.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        textfield.textColor = .label
        textfield.tintColor = .label
        textfield.returnKeyType = .done
        textfield.textAlignment = .left
        textfield.adjustsFontSizeToFitWidth = true
        textfield.placeholder = Strings.Compose.subject.localized.replacingOccurrences(of: ": ", with: "")
        return textfield
    }()
    
    private var anyCancellables = Set<AnyCancellable>()

    // MARK: - Constructor
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        anyCancellables.forEach({ $0.cancel() })
        anyCancellables.removeAll()
    }
    
    // MARK: - Lifecycle
    public override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        anyCancellables = [
            model
                .$content
                .receive(on: DispatchQueue.main)
                .map({ $0.description })
                .assign(to: \.text, on: subjectTextField),
            
            subjectTextField
                .textPublisher
                .debounce(for: 0.5, scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] (text) in
                    self?.model.subject.send(text)
                })
        ]
    }
    
    private func buildLayout() {
        backgroundColor = .systemBackground
        
        subjectTextField.delegate = self
        
        contentView.addSubview(subjectTextField)
        
        subjectTextField.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0))
        }
    }
    
    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? ComposeMailSubjectModel else {
            fatalError("Couldn't typecast ComposeMailSubjectModel")
        }
        self.model = model
        
        setupObservers()
        
        layoutIfNeeded()
    }
}

// MARK: - UITextFieldDelegate
extension ComposeMailSubjectCell: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

import Foundation
import UIKit
import Utility

public final class InboxViewerWebMailBodyCell: UITableViewCell, Cellable {
    
    // MARK: IBOutlets
    @IBOutlet weak var messageTextEditorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextEditor: RichEditorView!
    
    // MARK: Properties
    var thresholdHeight: CGFloat {
        return 200.0
    }
    
    var onHeightChange: (() -> Void)?
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.tintColor = AppStyle.Colors.loaderColor.color
        activity.hidesWhenStopped = true
        return activity
    }()
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .systemBackground
        setupEditor()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        messageTextEditor.setEditorFontColor(k_mailboxTextColor)
    }
    
    // MARK: - Setup UI
    private func setupEditor() {
        messageTextEditor.isScrollEnabled = false
        
        messageTextEditor.delegate = self
        
        messageTextEditor.editingEnabled = false
                
        messageTextEditor.setEditorFontColor(.label)
    }
    
    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? TextMail else {
            fatalError("Couldn't Find TextMail")
        }
        
        addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { (maker) in
            maker.center.centerX.centerY.equalToSuperview()
        }
        
        bringSubviewToFront(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        messageTextEditor.html = model.content
    }
}

// MARK: - RichEditorDelegate
extension InboxViewerWebMailBodyCell: RichEditorDelegate {
    public func richEditorTookFocus(_ editor: RichEditorView) {
    }
    
    public func richEditorLostFocus(_ editor: RichEditorView) {
        // model.update(content: "\(editor.contentHTML)")
    }
    
    public func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        activityIndicatorView.stopAnimating()
    }
    
    public func didBeginEditing() {
    }
    
    public func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        messageTextEditorHeightConstraint.constant = CGFloat(height)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.onHeightChange?()
        }
    }
}

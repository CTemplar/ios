import Foundation
import UIKit
import Utility
import SnapKit
import Combine

public final class ComposeMailBodyCell: UITableViewCell, Cellable {
    // MARK: IBOutlets
    @IBOutlet weak var messageTextEditorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextEditor: RichEditorView!
    
    // MARK: Properties
    private lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 44))
        toolbar.tintColor = AppStyle.Colors.loaderColor.color
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()

    var thresholdHeight: CGFloat {
        return 200.0
    }
    
    private var model: ComposeMailSubjectModel!

    private var anyCancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        messageTextEditor.setEditorFontColor(.label)
        messageTextEditor.placeholder = Strings.AppSettings.typeMessage.localized
    }

    // MARK: - Setup
    private func setupEditor() {
        messageTextEditor.inputAccessoryView = toolbar
        
        messageTextEditor.delegate = self
        
        messageTextEditor.isScrollEnabled = false
        
        toolbar.editor = messageTextEditor
        
        toolbar.delegate = self
        
        let clearItem = RichEditorOptionItem(image: nil,
                                             title: Strings.AppSettings.clear.localized) { (toolbar) in
            toolbar.editor?.html = ""
        }
        
        let doneItem = RichEditorOptionItem(image: nil,
                                            title: Strings.AppSettings.done.localized) { [weak self] (toolbar) in
            self?.messageTextEditor.endEditing(true)
        }
        
        var options = toolbar.options
        
        options.append(contentsOf: [clearItem, doneItem])
        
        toolbar.options = options
        
        messageTextEditor.setEditorFontColor(.label)
    }
    
    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? ComposeMailSubjectModel else {
            fatalError("Couldn't typecast ComposeMailSubjectModel")
        }
        self.model = model
        
        setupEditor()
        
        messageTextEditor.html = model.content
    }
}

// MARK: - RichEditorToolbarDelegate
extension ComposeMailBodyCell: RichEditorToolbarDelegate {
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
            .black,
            .darkGray,
            .brown
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    public func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    public func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    public func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.hasRangeSelection(handler: { [weak self] (isRangedSelection) in
            if isRangedSelection {
                let alert = UIAlertController(title: Strings.AppSettings.insertLink.localized,
                                              message: nil,
                                              preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.placeholder = Strings.AppSettings.urlRequired.localized
                }
                
                alert.addTextField { (textField) in
                    textField.placeholder = Strings.AppSettings.title.localized
                }
                
                alert.addAction(UIAlertAction(title: Strings.AppSettings.insert.localized,
                                              style: .default,
                                              handler:
                    { (action) in
                        let textField1 = alert.textFields?.first
                        let textField2 = alert.textFields?[1]
                        let url = textField1?.text ?? ""
                        if url.isEmpty {
                            return
                        }
                        let title = textField2?.text ?? ""
                        toolbar.editor?.insertLink(href: url, text: title)
                }))
                
                alert.addAction(UIAlertAction(title: Strings.Button.cancelButton.localized,
                                              style: .cancel, handler: nil))
                self?.parentViewController?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    public func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
    }
}

// MARK: - RichEditorDelegate
extension ComposeMailBodyCell: RichEditorDelegate {
    public func richEditorTookFocus(_ editor: RichEditorView) {
    }
    
    public func richEditorLostFocus(_ editor: RichEditorView) {
        // model.update(content: "\(editor.contentHTML)")
    }
    
    public func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        model.subject.send(content)
    }
    
    public func didBeginEditing() {
    }

    public func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        if height < Int(thresholdHeight) {
            model.cellHeight = 200.0
        } else {
            model.cellHeight = CGFloat(height)
        }
        
        messageTextEditorHeightConstraint.constant = model.cellHeight
        
        UIView.performWithoutAnimation {
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
            
            if let thisIndexPath = tableView?.indexPath(for: self) {
                tableView?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
}

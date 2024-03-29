import Foundation
import UIKit
import Utility
import SnapKit
import Combine
import Networking

public final class ComposeMailBodyCell: UITableViewCell, Cellable {
    // MARK: IBOutlets
    @IBOutlet weak var messageTextEditorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextEditor: RichEditorView!
    var user: UserMyself?

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
    
    private var keyboardHeight: CGFloat = .zero
    
    private var model: ComposeMailSubjectModel!

    private var anyCancellables = Set<AnyCancellable>()
    
    private var doneButton: RichEditorOptionItem?
    
    private var clearButton: RichEditorOptionItem?
    
    var indexRef:IndexPath = IndexPath(row: 0, section: 0)
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDismiss),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
       // messageTextEditor.setEditorFontColor(.label)
        messageTextEditor.placeholder = Strings.AppSettings.typeMessage.localized

        if (self.user != nil) {
            let textColor = self.getColorFromString(color: self.user?.settings.color ?? "none")
           let textbackgroundColor = self.getColorFromString(color: self.user?.settings.backgroundColor ?? "none")
          //messageTextEditor.webView.tintColor =
           if (textColor == .clear) {
               if (textbackgroundColor == .black) {
                   messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .white)
               }
               else {
                   messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .black)
               }
           }
           else {
               if (textColor == .white) {
                   if (textbackgroundColor == .clear) {
                      messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .black)
                   }
                   else {
                       messageTextEditor.setTextColor(textColor)
                   }
               }
               else if (textColor == .black) {
                   if (textbackgroundColor == .white) {
                       messageTextEditor.setTextColor(textColor)
                   }
                   else if (textbackgroundColor == .clear) {
                       messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .black)
                   }
                   else  if (textbackgroundColor == .black) {
                       messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .white)
                   }
                   else {
                       messageTextEditor.setTextColor(textColor)
                   }
               }
               else {
                   messageTextEditor.setTextColor(textColor)

               }
           }
         
           if (textbackgroundColor != .clear) {
               if (textbackgroundColor == .white) {
                   if (self.traitCollection.userInterfaceStyle == .dark) {
                       if (textColor == .white) {
                           messageTextEditor.setTextBackgroundColor(.black)
                       }
                       else {
                           messageTextEditor.setTextBackgroundColor(textbackgroundColor)
                       }
                   }
                   else {
                       messageTextEditor.setTextBackgroundColor(textbackgroundColor)
                   }
                   
               }
               else if (textbackgroundColor == .black) {
                   messageTextEditor.setTextBackgroundColor(textbackgroundColor)
               }
               else {
                   messageTextEditor.setTextBackgroundColor(textbackgroundColor)
               }
           }
           let newSize = self.user?.settings.size ?? 12
            let size = String(newSize/6)
           messageTextEditor.setTextFontSize(size)
           messageTextEditor.setTextFontName(self.user?.settings.plainTextFont ?? "Roboto" + "-Regular")
       }
    }
    
    private func getColorFromString(color:String)-> UIColor {
        switch color {
        case EditorColor.none:
            return .clear
        case EditorColor.red:
            return .red
        case EditorColor.blue:
            return .blue
        case EditorColor.green:
            return .green
        case EditorColor.white:
            return .white
        case EditorColor.pink:
            return .systemPink
        case EditorColor.grey:
            return .gray
        case EditorColor.black:
            return .black
        default:
           return .clear
        }
    }
    
    // MARK: - Observers
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            messageTextEditor.isScrollEnabled = true
            keyboardHeight = keyboardRectangle.size.height
            changeHeight(Int(keyboardHeight))
            tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRectangle.height, right: 0)
            tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRectangle.height, right: 0)
            tableView?.scrollToRow(at: indexRef, at: .top, animated: true)
        }
    }
    
    @objc
    private func keyboardWillDismiss(_ notification: Notification) {
        messageTextEditor.isScrollEnabled = false
        keyboardHeight = 0.0
        changeHeight(messageTextEditor.editorHeight)
    }

    // MARK: - Setup
    private func setupEditor() {
        messageTextEditor.updateEditorHTML(true)

        messageTextEditor.inputAccessoryView = toolbar
        
        messageTextEditor.delegate = self
        
        messageTextEditor.isScrollEnabled = false
        
        toolbar.editor = messageTextEditor
                
        toolbar.delegate = self
        
        var otherOptions: [RichEditorOption] = []

        if !toolbar.options.contains(where: { $0.title == Strings.AppSettings.clear.localized }) {
            clearButton = RichEditorOptionItem(image: nil,
                                                 title: Strings.AppSettings.clear.localized) { (toolbar) in
                toolbar.editor?.html = ""
            }
            otherOptions.append(clearButton!)
        }
        
        if !toolbar.options.contains(where: { $0.title == Strings.AppSettings.done.localized }) {
            doneButton = RichEditorOptionItem(image: nil,
                                                title: Strings.AppSettings.done.localized) { [weak self] (toolbar) in
                self?.messageTextEditor.endEditing(true)
            }
            otherOptions.append(doneButton!)
        }
                
        if !otherOptions.isEmpty {
            var options = toolbar.options
            
            options.append(contentsOf: otherOptions)
            
            toolbar.options = options
        }
        
       // messageTextEditor.setEditorFontColor(.label)
        
        // Setting the content type
        if model.contentType == .normalText {
            toolbar.disableAllOptions(except:
                [
                    RichEditorDefaultOption.more,
                    self.clearButton!,
                    self.doneButton!
                ]
            )
        }
        
        if (self.user != nil) {
             let textColor = self.getColorFromString(color: self.user?.settings.color ?? "none")
            let textbackgroundColor = self.getColorFromString(color: self.user?.settings.backgroundColor ?? "none")
           //messageTextEditor.webView.tintColor =
             if (textColor == .clear) {
                if (textbackgroundColor == .black) {
                    messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .white)
                }
                else {
                    messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .black)
                }
            }
            else {
                if (textColor == .white) {
                    if (textbackgroundColor == .clear) {
                       messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .black)
                    }
                    else {
                        messageTextEditor.setTextColor(textColor)
                    }
                }
                else if (textColor == .black) {
                    if (textbackgroundColor == .white) {
                        messageTextEditor.setTextColor(textColor)
                    }
                    else if (textbackgroundColor == .clear) {
                        messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .black)
                    }
                    else  if (textbackgroundColor == .black) {
                        messageTextEditor.setTextColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .white)
                    }
                    else {
                        messageTextEditor.setTextColor(textColor)
                    }
                }
                else {
                    messageTextEditor.setTextColor(textColor)

                }
            }
          
            if (textbackgroundColor != .clear) {
                if (textbackgroundColor == .white) {
                    if (self.traitCollection.userInterfaceStyle == .dark) {
                        if (textColor == .white) {
                            messageTextEditor.setTextBackgroundColor(.black)
                        }
                        else {
                            messageTextEditor.setTextBackgroundColor(textbackgroundColor)
                        }
                    }
                    else {
                        messageTextEditor.setTextBackgroundColor(textbackgroundColor)
                    }
                    
                }
                else if (textbackgroundColor == .black) {
                    messageTextEditor.setTextBackgroundColor(textbackgroundColor)
                }
                else {
                    messageTextEditor.setTextBackgroundColor(textbackgroundColor)
                }
            }
            let newSize = self.user?.settings.size ?? 12
             let size = String(newSize/6)
            messageTextEditor.setTextFontSize(size)
            messageTextEditor.setTextFontName(self.user?.settings.plainTextFont ?? "Roboto" + "-Regular")
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if model.content.contains("color=") {
            if model.content.contains("color=\"#000000\"") {
                if (model.content.contains("background-color:")) {
                    
                }
                else {
                    let newContent = self.traitCollection.userInterfaceStyle == .dark ? model.content.replacingOccurrences(of: "color=\"#000000\"", with: "color=\"#ffffff\"") : model.content
                     //model.content = newContent
                     messageTextEditor.html = newContent
     //                if model.contentType == .htmlText {
     //                    model.subject.send(newContent)
     //                }
                }
           }
            else  if model.content.contains("color=\"#ffffff\"") {
                if (model.content.contains("background-color:")) {
                    
                }
                else {
                    let newContent = self.traitCollection.userInterfaceStyle == .dark ? model.content : model.content.replacingOccurrences(of: "color=\"#ffffff\"", with: "color=\"#000000\"")
                    // model.content = newContent
                    messageTextEditor.html = newContent
                    //               if model.contentType == .htmlText {
                    //                   model.subject.send(newContent)
                    //               }
                }
            }
        }
        self.setupEditor()
    }
    
    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? ComposeMailSubjectModel else {
            fatalError("Couldn't typecast ComposeMailSubjectModel")
        }
        self.model = model
                
        setupEditor()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.messageTextEditor.html = model.content
        }
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
    
    public func onTapMore(_ toolbar: RichEditorToolbar) {
        let simpleTextTitle = model.contentType == .normalText ? "\(Strings.Compose.simpleText.localized) ✔︎" : Strings.Compose.simpleText.localized
        
        let htmlTextTitle = model.contentType == .htmlText ? "\(Strings.Compose.htmlText.localized) ✔︎" : Strings.Compose.htmlText.localized
        
        let alertController = UIAlertController(title: Strings.Compose.SelectDraftOption.localized,
                                                message: nil, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: simpleTextTitle,
                                        style: .default,
                                        handler:
            { [unowned self] (_) in
                self.model.contentTypeSubject.send(.normalText)
                toolbar.disableAllOptions(except:
                    [
                        RichEditorDefaultOption.more,
                        self.clearButton!,
                        self.doneButton!
                    ]
                )
        }))
        
        alertController.addAction(.init(title: htmlTextTitle,
                                        style: .default,
                                        handler:
            { [unowned self] (_) in
                self.model.contentTypeSubject.send(.htmlText)
                toolbar.enableAllOptions()
        }))
        
        alertController.addAction(.init(title: Strings.Button.cancelButton.localized,
                                        style: .cancel,
                                        handler:
            { (_) in
                toolbar.enableAllOptions()
        }))
        
        parentViewController?.present(alertController, animated: true, completion: nil)
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
        if model.contentType == .htmlText {
            model.subject.send(content)
        } else {
            editor.getText { [weak self] (text) in
                self?.model.subject.send(text)
            }
        }
    }
    
    public func didBeginEditing() {
    }

    public func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        changeHeight(height)
    }
    
    private func changeHeight(_ height: Int) {
        if UIApplication.shared.isKeyboardPresented, keyboardHeight > 0.0 {
            var actualHeight = keyboardHeight - thresholdHeight
            actualHeight = actualHeight < thresholdHeight ? thresholdHeight : actualHeight
            model.cellHeight = actualHeight
        } else {
            if height < Int(thresholdHeight) {
                model.cellHeight = 200.0
            } else {
                model.cellHeight = CGFloat(height)
            }
        }
                
        messageTextEditorHeightConstraint.constant = model.cellHeight
        
        UIView.performWithoutAnimation {
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
        }
    }
}
struct EditorColor {
    static let none = "none"
    static let red = "red"
    static let blue = "blue"
    static let green = "green"
    static let white = "white"
    static let black = "black"
    static let pink = "pink"
    static let grey = "grey"
}

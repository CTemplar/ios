import UIKit
import Utility
import SnapKit
import Combine

public class AttachmentCell: UITableViewCell, Cellable {
    // MARK: Properties
    private var models: [MailAttachment] = []
    private var viewModel: MailAttachmentCellModel!
    public var onTapAttachment: ((String, Bool, String) -> Void)?
    public var onDeleteAttachment: ((String) -> Void)?
    private var bindables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.register(AttachmentCollectionCell.self, forCellWithReuseIdentifier: AttachmentCollectionCell.className)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Constructor
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupObserver() {
        viewModel
            .$attachments
            .subscribe(on: RunLoop.main)
            .sink(receiveValue: { [weak self] in
                self?.models = $0
                self?.collectionView.reloadData()
        })
            .store(in: &bindables)
    }
    
    private func buildLayout() {
        backgroundColor = .systemBackground
        
        let view = UIView()
        view.backgroundColor = .systemBackground
        collectionView.backgroundView = view
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
            )
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = viewModel.spacing
        layout.minimumLineSpacing = viewModel.spacing
        layout.itemSize = CGSize(width: 100.0, height: 70.0)
        return layout
    }
    
    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? MailAttachmentCellModel else {
            fatalError("Couldn't Find AppSettingsModel")
        }
        self.viewModel = model
        
        buildLayout()
        
        setupObserver()

        self.models = model.attachments
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc
    private func onDeleteAttachment(from sender: UIButton) {
        let model = models[sender.tag]
        onDeleteAttachment?(model.contentURL)
    }
}

// MARK: - UICollectionViewDelegate & Data Source
extension AttachmentCell: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachmentCollectionCell.className, for: indexPath) as? AttachmentCollectionCell else {
            return UICollectionViewCell()
        }
        let model = models[indexPath.row]
        
        cell.configure(with: model)
       
        if model.shoulDisplayRemove {
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(onDeleteAttachment(from:)), for: .allTouchEvents)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        if var url = URL(string: model.contentURL) {
            if url.pathExtension == "__" {
                if let attachmentType = model.attachmentType.rawValue as? String{
                    url.deletePathExtension()
                    url.appendPathExtension(attachmentType)
                    onTapAttachment?(model.contentURL, model.encrypted, url.absoluteString)
                    return
                    
                }
            }
        }
        onTapAttachment?(model.contentURL, model.encrypted, "")
    }
}

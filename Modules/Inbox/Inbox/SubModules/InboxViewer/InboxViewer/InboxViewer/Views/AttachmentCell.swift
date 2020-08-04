import UIKit
import Utility
import SnapKit

public class AttachmentCell: UITableViewCell, Cellable {
    // MARK: Properties
    public typealias ModelType = MailAttachmentCellModel
    private var models: [MailAttachment] = []
    var onTapAttachment: ((String, Bool) -> Void)?
    
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
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
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
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 100.0, height: 70.0)
        return layout
    }
    
    // MARK: - Configuration
    public func configure(with model: MailAttachmentCellModel) {
        self.models = model.attachmentes
        collectionView.reloadData()
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
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        onTapAttachment?(model.contentURL, model.encrypted)
    }
}

//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

class ListViewController: UIViewController, UICollectionViewDelegate {
    
    enum Constants {
        static let Spacing: CGFloat = 16
        static let MediumSpacing: CGFloat = 12
    }
    
    enum Section {
        case main
    }
    
    enum ItemID: Hashable {
        case film(ImageCell.Configuration.ID)
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, ItemID>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: Self.PhotosLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ImageCell.Configuration> { (cell, indexPath, itemIdentifier) in
            cell.contentConfiguration = itemIdentifier
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, ItemID>(collectionView: collectionView) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            switch itemIdentifier {
            case .film(let id):
                let config = ImageCell.Configuration(id: id, image: UIImage(systemName: "pencil")!)
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: config)
            }
        }
    }
    
    private func applySnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.main])
        
        let ids = [
            UUID().uuidString,
            UUID().uuidString,
            UUID().uuidString,
            UUID().uuidString,
            UUID().uuidString,
        ]
        ids.forEach { id in
            snapshot.appendItems([.film(id)])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension ListViewController {
    
    private static var PhotosLayout: UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let spacing = NSCollectionLayoutSpacing.fixed(Constants.Spacing)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = Constants.Spacing
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: Constants.Spacing, leading: Constants.Spacing, bottom: 0, trailing: Constants.Spacing)
            return sectionLayout
        }
    }
}


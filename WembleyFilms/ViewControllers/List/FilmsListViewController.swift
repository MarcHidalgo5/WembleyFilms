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
    
    struct VM {
        let films: [ImageCell.Configuration]
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemID>!
    private var viewModel: VM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: Self.FilmsLayout)
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
                guard let config = self.viewModel.films.filter({ $0.id == id }).first else { fatalError() }
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: config)
            }
        }
    }
    
    private func applySnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.main])
        
        self.viewModel = .init(films: [
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!)
        ])
        self.viewModel.films.forEach { film in
            snapshot.appendItems([.film(film.id)])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension ListViewController {
    
    private static var FilmsLayout: UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let spacing = NSCollectionLayoutSpacing.fixed(Constants.Spacing)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = spacing
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.MediumSpacing, leading: Constants.MediumSpacing, bottom: Constants.MediumSpacing, trailing: Constants.MediumSpacing)
        section.interGroupSpacing = Constants.MediumSpacing / 2
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}


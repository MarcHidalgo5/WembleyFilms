//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

class ListViewController: UIViewController, UICollectionViewDelegate {
    
    init() {
        self.dataSource = Current.listDataSourceFactory()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private  enum Constants {
        static let Spacing: CGFloat = 16
        static let MediumSpacing: CGFloat = 12
    }
    
    private enum Section {
        case main
    }
    
    private enum ItemID: Hashable {
        case film(ImageCell.Configuration.ID)
    }
    
    struct VM {
        let films: [ImageCell.Configuration]
    }
    
    private let refreshControl = UIRefreshControl()
    private var collectionView: UICollectionView!
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, ItemID>!
    
    private var viewModel: VM!
    private let dataSource: ListDataSourceType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        configurePullToRefresh()
        fetchData()
    }
    
    //MARK: Private
    
    private func fetchData() {
        Task { @MainActor in
            do {
                let vm = try await dataSource.fetchFilmList()
                await configureFor(viewModel: vm)
            } catch {
                
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: Self.FilmsLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    private func configurePullToRefresh() {
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func handlePullToRefresh() {
        Task{ @MainActor in
            var snapshot = diffableDataSource.snapshot()
            await handlePullToRefresh(snapshot: &snapshot)
            await diffableDataSource.apply(snapshot, animatingDifferences: true)
            self.refreshControl.endRefreshing()
        }
    }
    
    private func handlePullToRefresh(snapshot: inout NSDiffableDataSourceSnapshot<Section, ItemID>) async {
        do {
            let vm = try await dataSource.fetchFilmList()
            self.viewModel = vm
            snapshot.deleteAllItems()
            snapshot.appendSections([.main])
            self.viewModel.films.forEach { film in
                snapshot.appendItems([.film(film.id)])
            }
        } catch {
//            self.showErrorAlert("walkthrough-error-message".localizedInMainBundle, error: error)
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ImageCell.Configuration> { (cell, indexPath, itemIdentifier) in
            cell.contentConfiguration = itemIdentifier
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource<Section, ItemID>(collectionView: collectionView) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            switch itemIdentifier {
            case .film(let id):
                guard let config = self.viewModel.films.filter({ $0.id == id }).first else { fatalError() }
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: config)
            }
        }
    }
    
    private func configureFor(viewModel: VM) async  {
        self.viewModel = viewModel
        var snapshot = diffableDataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        self.viewModel.films.forEach { film in
            snapshot.appendItems([.film(film.id)])
        }
        await diffableDataSource.apply(snapshot, animatingDifferences: true)
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


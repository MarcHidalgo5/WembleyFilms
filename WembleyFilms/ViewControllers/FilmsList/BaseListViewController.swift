//
//  Created by Marc Hidalgo on 4/6/23.
//

import UIKit

class BaseListViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    private enum Constants {
        static let Spacing: CGFloat = 16
        static let MediumSpacing: CGFloat = 12
    }
    
    enum Section {
        case main
        case empty
    }
    
    enum ItemID: Hashable {
        case film(ImageCell.Configuration.ID)
        case emtpy
    }
    
    struct VM {
        var films: [ImageCell.Configuration]
    }
    
    private var activityIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    private var collectionView: UICollectionView!
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, ItemID>!
    
    var viewModel: VM!
    
    var isRequestingNextPage: Bool = false
            
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configurePullToRefresh()
        configureActivityIndicator()
        configureDiffableDataSource()
        fetchData()
    }
    
    //MARK: Override
    
    open func fetchData() {
        fatalError("Implement fetchData")
    }
    
    open func fetchNextPage() {
        fatalError("Implement fetchNextPage")
    }
    
    open func searchData(text: String) {
        fatalError("Implement searchData")
    }
    
    open func handlePullToRefresh(snapshot: inout NSDiffableDataSourceSnapshot<Section, ItemID>) async {
        fatalError("Implement handlePullToRefresh")
    }
    
    open func didSelectFilm(id: Int) {
        fatalError("Implement didSelectFilm")
    }
    
    //MARK: Configuration
    
    private func configureDiffableDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ImageCell.Configuration> { (cell, indexPath, itemIdentifier) in
            cell.contentConfiguration = itemIdentifier
        }
        let emptyCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, EmptyCell.Configuration> { (cell, indexPath, itemIdentifier) in
            cell.contentConfiguration = itemIdentifier
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource<Section, ItemID>(collectionView: collectionView) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            switch itemIdentifier {
            case .film(let id):
                guard let config = self.viewModel.films.filter({ $0.id == id }).first else { fatalError() }
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: config)
            case .emtpy:
                return collectionView.dequeueConfiguredReusableCell(using: emptyCellRegistration, for: indexPath, item: EmptyCell.Configuration())
            }
        }
        
        setCollectionViewLayout()
    }
    
    private func setCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] rawValue, env in
            guard let self = self else { return Self.EmptyLayout }
            let snapshot = self.diffableDataSource.snapshot()
            let section = snapshot.sectionIdentifiers[rawValue]
            switch section {
            case .main:
                return Self.FilmsLayout
            case .empty:
                return Self.EmptyLayout
            }
        })
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func configureFor(viewModel: VM) async {
        self.viewModel = viewModel
        var snapshot = diffableDataSource.snapshot()
        snapshot.deleteAllItems()
        if self.viewModel.films.isEmpty {
            snapshot.appendSections([.empty])
            snapshot.appendItems([.emtpy], toSection: .empty)
        } else {
            snapshot.appendSections([.main])
            self.viewModel.films.forEach { film in
                snapshot.appendItems([.film(film.id)], toSection: .main)
            }
        }
        await diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func configureForPullRequest(viewModel: VM, snapshot: inout NSDiffableDataSourceSnapshot<BaseListViewController.Section, BaseListViewController.ItemID>) {
        self.viewModel = viewModel
        snapshot.deleteAllItems()
        if self.viewModel.films.isEmpty {
            snapshot.appendSections([.empty])
            snapshot.appendItems([.emtpy])
        } else {
            snapshot.appendSections([.main])
            self.viewModel.films.forEach { film in
                snapshot.appendItems([.film(film.id)])
            }
        }
    }
    
    func configureForNextPage(viewModel: VM) async {
        self.viewModel.films.append(contentsOf: viewModel.films)
        var snapshot = diffableDataSource.snapshot()
        viewModel.films.forEach { film in
            snapshot.appendItems([.film(film.id)], toSection: .main)
        }
        await diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor(named: "wembley-films-background-color")
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configurePullToRefresh() {
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    // MARK: Loading State Management
    
    func startLoading() {
        activityIndicator.startAnimating()
        collectionView.isUserInteractionEnabled = false
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        collectionView.isUserInteractionEnabled = true
    }
    
    //MARK: PullToRefresh
    
    @objc private func handlePullToRefresh() {
        Task{ @MainActor in
            var snapshot = diffableDataSource.snapshot()
            await handlePullToRefresh(snapshot: &snapshot)
            await diffableDataSource.apply(snapshot, animatingDifferences: true)
            self.refreshControl.endRefreshing()
        }
    }
}

extension BaseListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .film(let id):
            self.didSelectFilm(id: id)
        case .emtpy:
            break
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        guard offsetY > 0, contentHeight > 0 else { return }
        if offsetY > contentHeight - scrollView.frame.size.height {
            fetchNextPage()
        }
    }
}

//MARK: Layout

private extension BaseListViewController {
    private static var FilmsLayout: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let spacing = NSCollectionLayoutSpacing.fixed(Constants.Spacing)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = spacing
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.MediumSpacing, leading: Constants.MediumSpacing, bottom: Constants.MediumSpacing, trailing: Constants.MediumSpacing)
        section.interGroupSpacing = Constants.MediumSpacing / 2
        return section
    }
    
    static var EmptyLayout: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.MediumSpacing, bottom: Constants.MediumSpacing, trailing: Constants.MediumSpacing)
        return section
    }
}

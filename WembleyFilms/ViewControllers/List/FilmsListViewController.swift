//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

class ListViewController: UIViewController, UISearchResultsUpdating {
    
    init() {
        self.dataSource = Current.listDataSourceFactory()
        super.init(nibName: nil, bundle: nil)
    }
    
    private enum Constants {
        static let Spacing: CGFloat = 16
        static let MediumSpacing: CGFloat = 12
    }
    
    private enum Section {
        case main
        case empty
    }
    
    private enum ItemID: Hashable {
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
    
    private var viewModel: VM!
    private let dataSource: ListDataSourceType
    
    private var isRequestingNextPage: Bool = false
    
    let debouncer = Debouncer(interval: 0.5)
        
    var currentText: String?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.title = "Films"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = UISearchController.wembleyFilmsSearch()
        configureCollectionView()
        configurePullToRefresh()
        configureActivityIndicator()
        configureDiffableDataSource()
        fetchData()
        debouncer.callback = { [weak self] in
            guard let self = self else { return }
            if let text = self.currentText, !text.isEmpty {
                self.searchData(text: text)
            }
        }
    }
    
    //MARK: Private
    
    private func fetchData() {
        guard !isRequestingNextPage else { return }
        isRequestingNextPage = true
        startLoading()
        Task { @MainActor in
            do {
                let vm = try await dataSource.fetchFilmList()
                await configureFor(viewModel: vm)
                stopLoading()
                self.isRequestingNextPage = false
            } catch {
                self.showErrorAlert("Fail loading films", error: error)
                stopLoading()
                self.isRequestingNextPage = false
            }
        }
    }
    
    private func fetchNextPage() {
        guard !isRequestingNextPage else { return }
        isRequestingNextPage = true
        Task { @MainActor in
            do {
                let vm = try await dataSource.fetchNextPage()
                await configureForNextPage(viewModel: vm)
                self.isRequestingNextPage = false
            } catch {
                self.isRequestingNextPage = false
            }
        }
    }
    
    private func searchData(text: String) {
        isRequestingNextPage = true
        Task { @MainActor in
            do {
                let vm = try await self.dataSource.searchFilms(text: text)
                isRequestingNextPage = false
                await self.configureFor(viewModel: vm)
            } catch {
                isRequestingNextPage = false
            }
        }
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
    
    private func configureFor(viewModel: VM) async {
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
    
    private func configureForNextPage(viewModel: VM) async {
        self.viewModel.films.append(contentsOf: viewModel.films)
        var snapshot = diffableDataSource.snapshot()
        viewModel.films.forEach { film in
            snapshot.appendItems([.film(film.id)], toSection: .main)
        }
        await diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor(named: "wembley-film-background-color")
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
    
    private func startLoading() {
        activityIndicator.startAnimating()
        collectionView.isUserInteractionEnabled = false
    }
    
    private func stopLoading() {
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
    
    private func handlePullToRefresh(snapshot: inout NSDiffableDataSourceSnapshot<Section, ItemID>) async {
        do {
            let vm = try await dataSource.fetchFilmList()
            self.viewModel = vm
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
        } catch {
            self.showErrorAlert("Fail loading films", error: error)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = (searchController.searchBar.text ?? "")
        if text.isEmpty {
            self.currentText = nil
        } else {
            self.currentText = searchController.searchBar.text
        }
        debouncer.call()
    }
}

extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = FilmDetailsViewController()
        self.show(vc, sender: nil)
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

private extension ListViewController {
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

extension UISearchController {
    
    static func wembleyFilmsSearch() -> UISearchController {
        let resultsVC = ListViewController()
        let searchController = UISearchController(searchResultsController: resultsVC)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ""
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchResultsUpdater = resultsVC
        return searchController
    }
}


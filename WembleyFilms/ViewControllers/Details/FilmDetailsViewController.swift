//
//  Created by Marc Hidalgo on 4/6/23.
//

import UIKit

class FilmDetailsViewController: UIViewController {
    
    init(filmID: String) {
        self.currentFilmID = filmID
        self.dataSource = Current.filmDetaisDataSourceFactory()
        super.init(nibName: nil, bundle: nil)
//        self.title = currentFilm.title ?? ""
    }
    
    private enum Constants {
        static let Spacing: CGFloat = 16
        static let MediumSpacing: CGFloat = 12
    }
    
    enum Section {
        case image
        case text
        case button
    }

    enum Item: Hashable {
        case imageItem(ImageCell.Configuration)
        case textItem(TextCell.Configuration)
        case buttonItem(ButtonCell.Configuration)
    }
    
    struct VM {
        let image: ImageCell.Configuration
        let information: TextCell.Configuration
    }
    
    var currentFilmID: String
    
    var viewModel: VM!
    var collectionView: UICollectionView!
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    let dataSource: FilmDetailsDataSourceType!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDiffableDataSource()
        fetchData()
    }
    
    //MARK: Private
    
    private func fetchData() {
        Task { @MainActor in
            let a = try await self.dataSource.fetchFilmDetails(filmID: self.currentFilmID)
            print(a)
        }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    private func configureDiffableDataSource() {
        let imageCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ImageCell.Configuration> { (cell, indexPath, itemIdentifier) in
            cell.contentConfiguration = itemIdentifier
        }
        let textCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, TextCell.Configuration> { (cell, indexPath, itemIdentifier) in
            cell.contentConfiguration = itemIdentifier
        }
        let buttonCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ButtonCell.Configuration> { (cell, indexPath, itemIdentifier) in
            cell.contentConfiguration = itemIdentifier
        }
        diffableDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .imageItem(let config):
                return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: config)
            case .textItem(let config):
                return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: config)
            case .buttonItem(let config):
                return collectionView.dequeueConfiguredReusableCell(using: buttonCellRegistration, for: indexPath, item: config)
            }
        }
        
        setCollectionViewLayout()
        
        let image = UIImage(systemName: "pencil")!
        let text = " This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text"
        
        var snapshot = diffableDataSource.snapshot()
        snapshot.appendSections([.image, .text, .button])
        snapshot.appendItems([.imageItem(ImageCell.Configuration(imageURL: nil))], toSection: .image)
        snapshot.appendItems([.textItem(TextCell.Configuration(text: text))], toSection: .text)
        snapshot.appendItems([.buttonItem(ButtonCell.Configuration())], toSection: .button)
        diffableDataSource.apply(snapshot)
    }
    
    private func setCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] rawValue, env in
            guard let self = self else { return Self.EmptyLayout }
            let snapshot = self.diffableDataSource.snapshot()
            let section = snapshot.sectionIdentifiers[rawValue]
            switch section {
            case .image:
                return Self.ImageLayout
            case .text:
                return Self.TextLayout
            case .button:
                return Self.ButtonLayout
            }
        })
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

private extension FilmDetailsViewController {
    static var ImageLayout: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(400))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(400))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.MediumSpacing, leading: Constants.MediumSpacing, bottom: 0, trailing: Constants.MediumSpacing)
        return section
    }

    static var TextLayout: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Constants.MediumSpacing / 2
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.MediumSpacing, leading: Constants.MediumSpacing, bottom: Constants.MediumSpacing, trailing: Constants.MediumSpacing)
        return section
    }

    static var ButtonLayout: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.MediumSpacing, bottom: Constants.MediumSpacing, trailing: Constants.MediumSpacing)
        return section
    }
    
    static var EmptyLayout: NSCollectionLayoutSection {
        .init(group: .init(layoutSize: .init(widthDimension: .absolute(0), heightDimension: .absolute(0))))
    }
}

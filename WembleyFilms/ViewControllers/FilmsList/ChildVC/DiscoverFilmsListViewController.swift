//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation
import UIKit

class DiscoverFilmsListViewController: BaseListViewController {
    
    override init() {
        self.dataSource = Current.discoverFilmsDataSourceFactory()
        super.init()
        self.title = "Movies"
    }
    
    private var currentText: String?
    
    private let debouncer = Debouncer(interval: 0.5)
    
    private let dataSource: DiscoverFilmsDataSourceType
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = UISearchController.wembleyFilmsSearch()
       
        debouncer.callback = { [weak self] in
            guard let self = self else { return }
            if let text = self.currentText, !text.isEmpty {
                self.searchData(text: text)
            }
        }
    }
    
    override func fetchData() {
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
    
    override func fetchNextPage() {
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
    
    override func searchData(text: String) {
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
    
    override func handlePullToRefresh(snapshot: inout NSDiffableDataSourceSnapshot<BaseListViewController.Section, BaseListViewController.ItemID>) async {
        do {
            let vm = try await dataSource.fetchFilmList()
            #warning("Create configureForPullRequest")
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
    
    override func didSelectFilm(id: String) {
        let vc = FilmDetailsViewController(filmID: id)
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
    }
}

extension DiscoverFilmsListViewController: UISearchResultsUpdating {
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

extension UISearchController {
    
    static func wembleyFilmsSearch() -> UISearchController {
        let resultsVC = DiscoverFilmsListViewController()
        let searchController = UISearchController(searchResultsController: resultsVC)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ""
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchResultsUpdater = resultsVC
        return searchController
    }
}

//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation
import UIKit

class FavouriteFilmsListViewController: BaseListViewController {
    
    override init() {
        self.dataSource = Current.favouriteFilmsDataSourceFactory()
        super.init()
        self.title = "Favourites Movies"
    }
    
    private let dataSource: FavouriteFilmsDataSourceType
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFavourites),
            name: DidUpdateFavouriteNotification,
            object: nil
        )
    }
    
    override func fetchData() {
        guard !isRequestingNextPage else { return }
        isRequestingNextPage = true
        startLoading()
        Task { @MainActor in
            do {
                let vm = try await dataSource.fetchFavouriteFilms()
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
                let vm = try await dataSource.fetchFavouriteFilmsNextPage()
                await configureForNextPage(viewModel: vm)
                self.isRequestingNextPage = false
            } catch {
                self.isRequestingNextPage = false
            }
        }
    }
    
    override func handlePullToRefresh(snapshot: inout NSDiffableDataSourceSnapshot<BaseListViewController.Section, BaseListViewController.ItemID>) async {
        do {
            let vm = try await dataSource.fetchFavouriteFilms()
            self.configureForPullRequest(viewModel: vm, snapshot: &snapshot)
        } catch {
            self.showErrorAlert("Fail loading films", error: error)
        }
    }
    
    override func didSelectFilm(id: Int) {
        let vc = FilmDetailsViewController(filmID: id)
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
    }
    
    //MARK: Selector
    
    @objc func updateFavourites() {
        self.fetchData()
    }
}

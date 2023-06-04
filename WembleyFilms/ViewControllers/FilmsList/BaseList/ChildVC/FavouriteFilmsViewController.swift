//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation
import UIKit

class FavouriteFilmsViewController: BaseListViewController {
    
    override init() {
        super.init()
        self.title = "Favourites Movies"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            let vm = try await dataSource.fetchFavouriteFilmsNextPage()
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
    
}

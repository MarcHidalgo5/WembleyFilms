//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation

class Debouncer {
    var callback: (() -> Void)?
    private let interval: TimeInterval
    private var timer: Timer?

    init(interval: TimeInterval) {
        self.interval = interval
    }

    func call() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { [weak self] _ in
            self?.callback?()
        })
    }

    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}


import SwiftUI

class RandomListState: ObservableObject {
    @Published var items = [RandomListItem]()
    @Published var isCreateItemAlertShown = false
    @Published var isRandomPickAlertShown = false
    
    func beginCreatingItem() {
        isCreateItemAlertShown = true
    }
    
    func showRandomPick() {
        isRandomPickAlertShown = true
    }
}

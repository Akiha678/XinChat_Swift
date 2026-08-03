import Foundation

final class ConversationListViewModel {
    private let repository: ChatRepositoryProtocol
    private(set) var conversations: [Conversation] = []

    var onDataChanged: (() -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        conversations = repository.conversations()
        onDataChanged?()
    }
}

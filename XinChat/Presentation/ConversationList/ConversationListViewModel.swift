import Foundation

/// 会话列表 ViewModel，负责从 Repository 获取数据并通知页面刷新。
final class ConversationListViewModel {
    private let repository: ChatRepositoryProtocol
    private(set) var conversations: [Conversation] = []

    var onDataChanged: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    /// 加载会话数据。页面无需了解数据来源。
    func load() {
        onLoadingChanged?(true)
        repository.fetchConversations { [weak self] result in
            guard let self else { return }
            onLoadingChanged?(false)
            switch result {
            case let .success(conversations):
                self.conversations = conversations
                onDataChanged?()
            case let .failure(error):
                onError?(error.localizedDescription)
            }
        }
    }
}

import Foundation

/// 会话列表 ViewModel，负责从 Repository 获取数据并通知页面刷新。
final class ConversationListViewModel {
    private let repository: ChatRepositoryProtocol
    private(set) var conversations: [Conversation] = []

    var onDataChanged: (() -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    /// 加载会话数据。页面无需了解数据来源。
    func load() {
        conversations = repository.conversations()
        onDataChanged?()
    }
}

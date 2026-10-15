import Foundation

/// 会话列表 ViewModel，负责从 Repository 获取数据并通知页面刷新。
final class ConversationListViewModel {
    private let repository: ChatRepositoryProtocol
    private let realtimeClient: ChatRealtimeClientProtocol
    private var realtimeObserver: UUID?
    private var isLoading = false
    private var needsReload = false
    private(set) var conversations: [Conversation] = []

    var onDataChanged: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onUnreadCountChanged: ((Int) -> Void)?

    init(repository: ChatRepositoryProtocol, realtimeClient: ChatRealtimeClientProtocol) {
        self.repository = repository
        self.realtimeClient = realtimeClient
    }

    deinit {
        if let realtimeObserver {
            realtimeClient.removeObserver(realtimeObserver)
        }
    }

    /// 会话列表在应用生命周期内保持订阅，隐藏在其他 Tab 时也能接收刷新信号。
    func activate() {
        guard realtimeObserver == nil else { return }
        realtimeObserver = realtimeClient.observe { [weak self] event in
            switch event {
            case .connected, .friendshipChanged, .messageCreated, .conversationRead:
                self?.load()
            case .disconnected:
                break
            }
        }
    }

    /// 加载会话数据。页面无需了解数据来源。
    func load() {
        guard !isLoading else {
            needsReload = true
            return
        }
        isLoading = true
        onLoadingChanged?(true)
        repository.fetchConversations { [weak self] result in
            guard let self else { return }
            isLoading = false
            onLoadingChanged?(false)
            switch result {
            case let .success(conversations):
                self.conversations = conversations
                onDataChanged?()
                onUnreadCountChanged?(conversations.reduce(0) { $0 + $1.unreadCount })
            case let .failure(error):
                onError?(error.localizedDescription)
            }
            if needsReload {
                needsReload = false
                load()
            }
        }
    }
}

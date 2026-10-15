import Foundation

/// 聊天详情 ViewModel，负责历史同步、实时事件合并和消息发送。
final class ChatViewModel {
    let conversation: Conversation
    private let repository: ChatRepositoryProtocol
    private let realtimeClient: ChatRealtimeClientProtocol
    private var realtimeObserver: UUID?
    private(set) var messages: [ChatMessage] = []

    var onDataChanged: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    init(
        conversation: Conversation,
        repository: ChatRepositoryProtocol,
        realtimeClient: ChatRealtimeClientProtocol
    ) {
        self.conversation = conversation
        self.repository = repository
        self.realtimeClient = realtimeClient
    }

    /// 页面可见时订阅实时事件，并通过 REST 做一次基线同步。
    func activate() {
        guard realtimeObserver == nil else { return }
        realtimeObserver = realtimeClient.observe { [weak self] event in
            guard let self else { return }
            switch event {
            case .connected:
                // 重连期间可能遗漏事件，连接恢复后必须从事实来源补齐。
                loadMessages(showLoading: messages.isEmpty)
            case let .messageCreated(message):
                guard message.conversationId == conversation.id else { return }
                merge([message])
                markRead()
            case .friendshipChanged:
                break
            case .conversationRead:
                break
            case .disconnected:
                break
            }
        }
        loadMessages(showLoading: messages.isEmpty)
    }

    /// 页面不可见时取消 UI 订阅；应用级连接仍保持，用于快速恢复。
    func deactivate() {
        guard let realtimeObserver else { return }
        realtimeClient.removeObserver(realtimeObserver)
        self.realtimeObserver = nil
    }

    // 加载消息
    func loadMessages() {
        loadMessages(showLoading: messages.isEmpty)
    }

    private func loadMessages(showLoading: Bool) {
        if showLoading { onLoadingChanged?(true) }
        repository.fetchMessages(conversationID: conversation.id) { [weak self] result in
            guard let self else { return }
            if showLoading { onLoadingChanged?(false) }
            switch result {
            case let .success(remoteMessages):
                merge(remoteMessages)
                markRead()
            case let .failure(error):
                onError?(error.localizedDescription)
            }
        }
    }
    // 发送消息
    func send(text: String) {
        repository.sendMessage(conversationID: conversation.id, content: text) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(message):
                // 服务端也会通过 WebSocket 回推同一消息，按 ID 合并可消除竞态重复。
                merge([message])
            case let .failure(error):
                onError?(error.localizedDescription)
            }
        }
    }

    private func merge(_ incoming: [ChatMessage]) {
        var indexed = Dictionary(uniqueKeysWithValues: messages.map { ($0.id, $0) })
        incoming.forEach { indexed[$0.id] = $0 }
        let merged = indexed.values.sorted { $0.id < $1.id }
        guard merged != messages else { return }
        messages = merged
        onDataChanged?()
    }

    /// 页面处于当前会话时推进服务端已读游标，未读数由服务端统一计算。
    private func markRead() {
        repository.markConversationRead(conversationID: conversation.id) { _ in }
    }
}

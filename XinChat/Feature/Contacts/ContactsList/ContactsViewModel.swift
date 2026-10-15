import Foundation

/// 联系人页面 ViewModel，将网络过程转换为页面可直接渲染的状态。
final class ContactsViewModel {
    /// 联系人列表的完整页面状态，保证 loading、content 与 error 互斥。
    enum State {
        case idle
        case loading
        case loaded(contacts: [Contact], pendingRequestCount: Int)
        case failed(String)
    }

    private let repository: ChatRepositoryProtocol
    private(set) var state: State = .idle {
        didSet { onStateChanged?(state) }
    }

    var onStateChanged: ((State) -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    /// 重新请求联系人；同时供首次加载和下拉刷新调用。
    func load() {
        state = .loading
        let group = DispatchGroup()
        var contactsResult: Result<[Contact], NetworkError>?
        var requestsResult: Result<[FriendRequest], NetworkError>?

        group.enter()
        repository.fetchContacts { result in
            contactsResult = result
            group.leave()
        }
        group.enter()
        repository.fetchIncomingFriendRequests { result in
            requestsResult = result
            group.leave()
        }
        group.notify(queue: .main) { [weak self] in
            guard let self, let contactsResult, let requestsResult else { return }
            switch (contactsResult, requestsResult) {
            case let (.success(contacts), .success(requests)):
                state = .loaded(contacts: contacts, pendingRequestCount: requests.count)
            case let (.failure(error), _), let (_, .failure(error)):
                state = .failed(error.localizedDescription)
            }
        }
    }

    /// 为指定好友创建或复用单聊会话。
    func createConversation(
        with contact: Contact,
        completion: @escaping (Result<Conversation, NetworkError>) -> Void
    ) {
        repository.createDirectConversation(friendID: contact.id, completion: completion)
    }
}

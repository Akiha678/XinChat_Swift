import Foundation

/// 添加好友页面 ViewModel，负责候选用户搜索和好友申请状态管理。
final class AddFriendViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum RequestState: Equatable {
        case available
        case sending
        case sent
    }

    private let repository: ChatRepositoryProtocol
    private var allContacts: [Contact] = []
    private var requestStates: [Int: RequestState] = [:]

    private(set) var visibleContacts: [Contact] = []
    private(set) var loadState: LoadState = .idle

    var onDataChanged: (() -> Void)?
    var onLoadStateChanged: ((LoadState) -> Void)?
    var onError: ((String) -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    /// 加载可添加的候选用户。
    func load() {
        loadState = .loading
        onLoadStateChanged?(loadState)
        repository.fetchFriendCandidates(keyword: "") { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(contacts):
                allContacts = contacts
                visibleContacts = contacts
                loadState = .loaded
                onLoadStateChanged?(loadState)
                onDataChanged?()
            case let .failure(error):
                loadState = .failed(error.localizedDescription)
                onLoadStateChanged?(loadState)
            }
        }
    }

    /// 按姓名、用户名或邮箱过滤候选用户。
    func search(query: String) {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            visibleContacts = allContacts
            onDataChanged?()
            return
        }

        visibleContacts = allContacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(keyword)
                || contact.username.localizedCaseInsensitiveContains(keyword)
                || contact.email.localizedCaseInsensitiveContains(keyword)
        }
        onDataChanged?()
    }

    func requestState(for contact: Contact) -> RequestState {
        requestStates[contact.id] ?? .available
    }

    /// 发送好友申请，并防止同一联系人重复提交。
    func sendRequest(to contact: Contact) {
        guard requestState(for: contact) == .available else { return }
        requestStates[contact.id] = .sending
        onDataChanged?()

        repository.sendFriendRequest(contactID: contact.id) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                requestStates[contact.id] = .sent
            case let .failure(error):
                requestStates[contact.id] = .available
                onError?(error.localizedDescription)
            }
            onDataChanged?()
        }
    }
}

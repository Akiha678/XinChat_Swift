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
    private var requestStates: [Int: RequestState] = [:]
    private var searchWorkItem: DispatchWorkItem?
    private(set) var query = ""

    private(set) var visibleContacts: [Contact] = []
    private(set) var loadState: LoadState = .idle

    var onDataChanged: (() -> Void)?
    var onLoadStateChanged: ((LoadState) -> Void)?
    var onError: ((String) -> Void)?
    var onNotice: ((String) -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    /// 页面初始状态不枚举用户，必须输入用户名后搜索。
    func load() {
        visibleContacts = []
        loadState = .loaded
        onLoadStateChanged?(loadState)
        onDataChanged?()
    }

    /// 按用户名访问服务端搜索，防抖避免每次键入都产生请求。
    func search(query: String) {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        self.query = keyword
        searchWorkItem?.cancel()
        guard !keyword.isEmpty else {
            visibleContacts = []
            loadState = .loaded
            onLoadStateChanged?(loadState)
            onDataChanged?()
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(keyword: keyword)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    func searchImmediately() {
        searchWorkItem?.cancel()
        guard !query.isEmpty else { return }
        performSearch(keyword: query)
    }

    private func performSearch(keyword: String) {
        loadState = .loading
        onLoadStateChanged?(loadState)
        repository.fetchFriendCandidates(keyword: keyword) { [weak self] result in
            guard let self, keyword == query else { return }
            switch result {
            case let .success(contacts):
                visibleContacts = contacts
                loadState = .loaded
                onLoadStateChanged?(loadState)
                onDataChanged?()
            case let .failure(error):
                visibleContacts = []
                loadState = .failed(error.localizedDescription)
                onLoadStateChanged?(loadState)
            }
        }
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
                onNotice?("好友申请已发送，等待对方同意")
            case let .failure(error):
                requestStates[contact.id] = .available
                onError?(error.localizedDescription)
            }
            onDataChanged?()
        }
    }
}

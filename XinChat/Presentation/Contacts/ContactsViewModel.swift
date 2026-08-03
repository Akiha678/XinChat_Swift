import Foundation

/// 联系人页面 ViewModel，将网络过程转换为页面可直接渲染的状态。
final class ContactsViewModel {
    /// 联系人列表的完整页面状态，保证 loading、content 与 error 互斥。
    enum State {
        case idle
        case loading
        case loaded([Contact])
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
        repository.fetchContacts { [weak self] result in
            switch result {
            case let .success(contacts): self?.state = .loaded(contacts)
            case let .failure(error): self?.state = .failed(error.localizedDescription)
            }
        }
    }
}

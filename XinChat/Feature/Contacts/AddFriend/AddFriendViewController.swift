import SnapKit
import UIKit

/// 添加好友页面，提供候选用户搜索、好友申请和请求状态反馈。
final class AddFriendViewController: UIViewController {
    private let viewModel: AddFriendViewModel
    private let appBar = AppBarView(title: "添加好友")
    private let searchBar = UISearchBar()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    init(viewModel: AddFriendViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup & Binding

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        appBar.onBackTapped = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        searchBar.placeholder = "输入用户名搜索"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self

        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = 70
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.register(AddFriendCell.self, forCellReuseIdentifier: AddFriendCell.reuseIdentifier)

        messageLabel.textColor = AppTheme.secondaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true

        [appBar, searchBar, tableView, loadingView, messageLabel].forEach(view.addSubview)
        appBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(AppBarView.contentHeight)
        }
        searchBar.snp.makeConstraints {
            $0.top.equalTo(appBar.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        loadingView.snp.makeConstraints { $0.center.equalTo(tableView) }
        messageLabel.snp.makeConstraints {
            $0.center.equalTo(tableView)
            $0.leading.trailing.equalToSuperview().inset(36)
        }
    }

    private func bind() {
        viewModel.onDataChanged = { [weak self] in self?.renderData() }
        viewModel.onLoadStateChanged = { [weak self] state in self?.renderLoadState(state) }
        viewModel.onError = { [weak self] message in self?.showError(message) }
        viewModel.onNotice = { [weak self] message in self?.showNotice(message) }
    }

    // MARK: - Rendering

    private func renderData() {
        tableView.reloadData()
        messageLabel.text = viewModel.query.isEmpty ? "输入用户名查找好友" : "没有找到可添加的用户"
        messageLabel.isHidden = !viewModel.visibleContacts.isEmpty
    }

    private func renderLoadState(_ state: AddFriendViewModel.LoadState) {
        switch state {
        case .idle:
            break
        case .loading:
            messageLabel.isHidden = true
            loadingView.startAnimating()
        case .loaded:
            loadingView.stopAnimating()
        case let .failed(message):
            loadingView.stopAnimating()
            messageLabel.text = "\(message)\n请返回后重试"
            messageLabel.isHidden = false
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "发送失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }

    private func showNotice(_ message: String) {
        let alert = UIAlertController(title: "申请已发送", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension AddFriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.visibleContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AddFriendCell.reuseIdentifier,
            for: indexPath
        ) as? AddFriendCell else { return UITableViewCell() }

        let contact = viewModel.visibleContacts[indexPath.row]
        cell.configure(contact: contact, state: viewModel.requestState(for: contact)) { [weak self] in
            self?.viewModel.sendRequest(to: contact)
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension AddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.searchImmediately()
    }
}

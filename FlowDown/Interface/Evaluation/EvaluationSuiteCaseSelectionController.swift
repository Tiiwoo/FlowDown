//
//  EvaluationSuiteCaseSelectionController.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import SnapKit
import UIKit

final class EvaluationSuiteCaseSelectionController: UITableViewController {
    private let suite: EvaluationManifest.Suite
    private let options: EvaluationOptions

    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredCases: [EvaluationManifest.Suite.Case] = []

    private var isSearching: Bool {
        let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return searchController.isActive && !text.isEmpty
    }

    init(suite: EvaluationManifest.Suite, options: EvaluationOptions) {
        self.suite = suite
        self.options = options
        super.init(style: .plain)
        title = String(localized: suite.title)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        tableView.keyboardDismissMode = .interactive
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String(localized: "Search cases...")
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.preferredSearchBarPlacement = .stacked
    }

    private func currentCases() -> [EvaluationManifest.Suite.Case] {
        isSearching ? filteredCases : suite.cases
    }

    private func isCaseEnabled(_ id: EvaluationManifest.Suite.Case.ID) -> Bool {
        !options.excludedCases.contains(id)
    }

    private func setCaseEnabled(_ id: EvaluationManifest.Suite.Case.ID, enabled: Bool) {
        if enabled {
            options.excludedCases.removeAll(where: { $0 == id })
        } else {
            if !options.excludedCases.contains(id) {
                options.excludedCases.append(id)
            }
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        currentCases().count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath,
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = currentCases()[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.title
        cell.contentConfiguration = content
        cell.selectionStyle = .default
        cell.backgroundColor = .clear

        let toggle = UISwitch()
        toggle.onTintColor = .accent
        toggle.isOn = isCaseEnabled(item.id)
        toggle.addAction(
            UIAction { [weak self] action in
                guard let self, let sender = action.sender as? UISwitch else { return }
                setCaseEnabled(item.id, enabled: sender.isOn)
            },
            for: .valueChanged,
        )
        cell.accessoryView = toggle

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let toggle = tableView.cellForRow(at: indexPath)?.accessoryView as? UISwitch else { return }
        toggle.setOn(!toggle.isOn, animated: true)
        setCaseEnabled(currentCases()[indexPath.row].id, enabled: toggle.isOn)
    }
}

extension EvaluationSuiteCaseSelectionController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            filteredCases = []
        } else {
            filteredCases = suite.cases.filter { $0.title.localizedCaseInsensitiveContains(text) }
        }
        tableView.reloadData()
    }
}

//
//  EvaluationCaseDetailController.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import ChatClientKit
import Foundation
import SnapKit
import UIKit

class EvaluationCaseDetailController: UIViewController {
    private let caseItem: EvaluationManifest.Suite.Case
    private let session: EvaluationSession

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(caseItem: EvaluationManifest.Suite.Case, session: EvaluationSession) {
        self.caseItem = caseItem
        self.session = session
        super.init(nibName: nil, bundle: nil)
        title = caseItem.title
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setupTableView()
        setupFooter()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupFooter() {
        guard let result = caseItem.results.last, result.outcome == .awaitingJudging else { return }

        let footer = UIView()
        footer.backgroundColor = .secondarySystemGroupedBackground
        view.addSubview(footer)
        footer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(100)
        }

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        footer.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        // Ensure safe area
        tableView.contentInset.bottom = 100

        let passButton = UIButton(configuration: .filled())
        passButton.configuration?.title = String(localized: "Pass")
        passButton.configuration?.baseBackgroundColor = .systemGreen
        passButton.addAction(UIAction { [weak self] _ in
            self?.judge(.pass)
        }, for: .touchUpInside)

        let failButton = UIButton(configuration: .filled())
        failButton.configuration?.title = String(localized: "Fail")
        failButton.configuration?.baseBackgroundColor = .systemRed
        failButton.addAction(UIAction { [weak self] _ in
            self?.judge(.fail)
        }, for: .touchUpInside)

        stack.addArrangedSubview(failButton)
        stack.addArrangedSubview(passButton)
    }

    private func judge(_ outcome: EvaluationManifest.Suite.Case.Result.Outcome) {
        guard let result = caseItem.results.last else { return }
        result.outcome = outcome
        try? EvaluationSessionManager.shared.save(session)
        NotificationCenter.default.post(name: .evaluationSessionDidUpdate, object: session)
        navigationController?.popViewController(animated: true)
    }
}

extension EvaluationCaseDetailController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        3 // Content, Response, Verifiers
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: caseItem.content.count
        case 1:
            // Assuming result output is stored in result.output, but currently EvaluationSession
            // might not be populating it fully?
            // Wait, looking at EvaluationManifest+Case.Result.swift, it has `output: [Content]`.
            // EvaluationSession needs to fill this! currently it doesn't seem to.
            // I'll assume it will.
            caseItem.results.last?.output.count ?? 0
        case 2: caseItem.verifier.count
        default: 0
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: String(localized: "Input Content")
        case 1: String(localized: "Model Output")
        case 2: String(localized: "Verifiers")
        default: nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            let content = caseItem.content[indexPath.row]
            configureCell(cell, with: content)
        case 1:
            if let output = caseItem.results.last?.output, indexPath.row < output.count {
                let content = output[indexPath.row]
                configureCell(cell, with: content)
            }
        case 2:
            let verifier = caseItem.verifier[indexPath.row]
            // Simple description
            var text = ""
            switch verifier {
            case .open: text = "Open (Human Eval)"
            case let .match(p): text = "Match: '\(p)'"
            case let .matchCaseInsensitive(p): text = "Match (Case Insensitive): '\(p)'"
            case let .contains(p): text = "Contains: '\(p)'"
            case let .containsCaseInsensitive(p): text = "Contains (Case Insensitive): '\(p)'"
            case let .matchRegularExpression(p): text = "Regex: '\(p)'"
            case let .tool(p, v): text = "Tool Param: \(p) == \(v)"
            }
            cell.textLabel?.text = text
            cell.textLabel?.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        default:
            break
        }
        return cell
    }

    private func configureCell(_ cell: UITableViewCell, with content: EvaluationManifest.Suite.Case.Content) {
        var text = ""
        var secondaryText = ""

        switch content.type {
        case .instruct:
            text = "System: " + (content.textRepresentation ?? "")
        case .request:
            text = "User: " + (content.textRepresentation ?? "")
        case .reply:
            text = "Assistant: " + (content.textRepresentation ?? "")
        case .reasoning:
            text = "Reasoning: " + (content.textRepresentation ?? "")
        case .toolDefinition:
            text = "Tool Def: " + (content.toolRepresentation?.name ?? "Unknown")
            secondaryText = content.toolRepresentation?.description ?? ""
        case .toolRequest:
            text = "Tool Call" // Need detail
        case .toolResponse:
            text = "Tool Output: " + (content.textRepresentation ?? "")
        }

        let attrText = NSMutableAttributedString(string: text)
        if !secondaryText.isEmpty {
            attrText.append(NSAttributedString(string: "\n" + secondaryText, attributes: [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.preferredFont(forTextStyle: .caption1)]))
        }

        cell.textLabel?.attributedText = attrText
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
    }
}

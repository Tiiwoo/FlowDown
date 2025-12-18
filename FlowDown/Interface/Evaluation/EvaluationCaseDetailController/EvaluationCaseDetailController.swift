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
        view.backgroundColor = .systemBackground

        setupTableView()
        setupFooter()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EvaluationContentCell.self, forCellReuseIdentifier: "ContentCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
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
        _ = try? EvaluationSessionManager.shared.save(session)
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
        switch indexPath.section {
        case 0, 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as! EvaluationContentCell
            let content: EvaluationManifest.Suite.Case.Content
            if indexPath.section == 0 {
                content = caseItem.content[indexPath.row]
            } else {
                guard let output = caseItem.results.last?.output, indexPath.row < output.count else {
                    return UITableViewCell()
                }
                content = output[indexPath.row]
            }
            configureContentCell(cell, with: content)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
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
            cell.backgroundColor = .secondarySystemGroupedBackground
            return cell
        default:
            return UITableViewCell()
        }
    }

    private func configureContentCell(_ cell: EvaluationContentCell, with content: EvaluationManifest.Suite.Case.Content) {
        var typeText = ""
        var bodyText = ""
        var secondaryText = ""
        var typeIcon: String?

        switch content.type {
        case .instruct:
            typeText = "System Instruction"
            typeIcon = "gearshape.2"
            bodyText = content.textRepresentation ?? ""
        case .request:
            typeText = "User Request"
            typeIcon = "person.fill.viewframe"
            bodyText = content.textRepresentation ?? ""
        case .reply:
            typeText = "Assistant Reply"
            typeIcon = "sparkles"
            bodyText = content.textRepresentation ?? ""
        case .reasoning:
            typeText = "Reasoning" // CoT
            typeIcon = "brain.head.profile"
            bodyText = content.textRepresentation ?? ""
        case .toolDefinition:
            typeText = "Tool Definition"
            typeIcon = "hammer.fill"
            bodyText = content.toolRepresentation?.name ?? "Unknown"
            secondaryText = content.toolRepresentation?.description ?? ""
        case .toolRequest:
            typeText = "Tool Call"
            typeIcon = "phone.arrow.up.right"
            if let toolName = content.toolRepresentation?.name {
                bodyText = "Calling: \(toolName)"
            } else {
                bodyText = "Calling Tool..."
            }
        case .toolResponse:
            typeText = "Tool Output"
            typeIcon = "phone.arrow.down.left"
            bodyText = content.textRepresentation ?? ""
        }

        // Header Configuration
        if let iconName = typeIcon, let iconImage = UIImage(systemName: iconName) {
            let attachment = NSTextAttachment()
            attachment.image = iconImage.withTintColor(.secondaryLabel)
            attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
            let attrParams: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel,
            ]
            let attributedString = NSMutableAttributedString(attachment: attachment)
            attributedString.append(NSAttributedString(string: "  " + typeText, attributes: attrParams))
            cell.headerLabel.attributedText = attributedString
        } else {
            cell.headerLabel.text = typeText
        }

        // Body Configuration
        cell.bodyLabel.text = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !secondaryText.isEmpty {
            cell.bodyLabel.text = (cell.bodyLabel.text ?? "") + "\n\n" + secondaryText
        }
    }
}

class EvaluationContentCell: UITableViewCell {
    let headerLabel = UILabel()
    let bodyLabel = UILabel()
    let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.backgroundColor = .secondarySystemGroupedBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.cornerCurve = .continuous
        containerView.clipsToBounds = true

        containerView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(6)
            make.horizontalEdges.equalToSuperview().inset(16)
        }

        containerView.addSubview(headerLabel)
        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = .secondaryLabel
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }

        containerView.addSubview(bodyLabel)
        bodyLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        bodyLabel.numberOfLines = 0
        bodyLabel.textColor = .label
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}

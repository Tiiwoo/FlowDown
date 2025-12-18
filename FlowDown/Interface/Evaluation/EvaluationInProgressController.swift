//
//  EvaluationInProgressController.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import AlertController
import SnapKit
import UIKit

class EvaluationInProgressController: UIViewController {
    let session: EvaluationSession

    private var sections: [(suite: EvaluationManifest.Suite, cases: [EvaluationManifest.Suite.Case])] = []

    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let statusLabel = UILabel()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .systemGroupedBackground
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in
    }

    private let cellRegistration = UICollectionView.CellRegistration<EvaluationCardCell, EvaluationManifest.Suite.Case> { cell, _, item in
        cell.configure(with: item)
    }

    init(session: EvaluationSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
        prepareData()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "Evaluating")
        view.backgroundColor = .systemGroupedBackground

        setupNavigation()
        setupHeader()
        setupCollectionView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionDidUpdate),
            name: .evaluationSessionDidUpdate,
            object: session,
        )

        session.resume()
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "stop.circle"),
            style: .plain,
            target: self,
            action: #selector(stopTapped),
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }

    @objc private func stopTapped() {
        session.stop()
        let alert = AlertViewController(
            title: String(localized: "Session Stopped"),
            message: String(localized: "Progress has been saved. You can resume this session later."),
        ) { context in
            context.addAction(title: "OK", attribute: .accent) {
                context.dispose { [weak self] in
                    self?.dismiss(animated: true)
                }
            }
        }
        present(alert, animated: true)
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(120),
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120),
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44),
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top,
        )
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

    @objc private func sessionDidUpdate() {
        DispatchQueue.main.async {
            self.updateProgress()
            self.collectionView.reloadData()
        }
    }

    func updateProgress() {
        var total = 0
        var completed = 0
        var passed = 0
        var failed = 0

        for manifest in session.manifests {
            for suite in manifest.suites {
                total += suite.cases.count
                for caseItem in suite.cases {
                    if let result = caseItem.results.last {
                        if result.outcome != .notDetermined, result.outcome != .processing {
                            completed += 1
                        }
                        if result.outcome == .pass { passed += 1 }
                        if result.outcome == .fail { failed += 1 }
                    }
                }
            }
        }

        let progress = total > 0 ? Float(completed) / Float(total) : 0
        progressView.setProgress(progress, animated: true)

        if completed == total {
            statusLabel.text = String(localized: "Completed. Passed: \(passed), Failed: \(failed)")
            statusLabel.textColor = .secondaryLabel
            navigationItem.rightBarButtonItem = nil // Hide stop button when done
        } else {
            statusLabel.text = String(localized: "Running... \(completed)/\(total) (Passed: \(passed))")
            statusLabel.textColor = .accent
        }
    }

    private func prepareData() {
        sections = session.manifests.flatMap { manifest in
            manifest.suites.map { suite in
                (suite: suite, cases: suite.cases)
            }
        }
    }

    private func setupHeader() {
        let headerContainer = UIView()
        headerContainer.backgroundColor = .clear

        view.addSubview(headerContainer)
        headerContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(60)
        }

        headerContainer.addSubview(progressView)
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .accent
        progressView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(60) // Increase hit area invisible but track is same? No, keeping styling.
            make.height.equalTo(6)
        }
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true

        statusLabel.text = String(localized: "Initializing...")
        statusLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center

        headerContainer.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(70)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension EvaluationInProgressController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].cases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].cases[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return UICollectionReusableView()
    }

    func collectionView(_: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader, let listCell = view as? UICollectionViewListCell {
            var content = listCell.defaultContentConfiguration()
            content.text = String(localized: sections[indexPath.section].suite.title)
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.textProperties.color = .secondaryLabel
            listCell.contentConfiguration = content
            listCell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = sections[indexPath.section].cases[indexPath.item]
        let detailVC = EvaluationCaseDetailController(caseItem: item, session: session)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

class EvaluationCardCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let statusIcon = UIImageView()
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true

        // Shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false

        contentView.addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
        }

        contentView.addSubview(statusIcon)
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(12)
            make.size.equalTo(24)
        }

        contentView.addSubview(statusLabel)
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview().inset(12)
            make.trailing.equalTo(statusIcon.snp.leading).offset(-8)
        }

        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(statusIcon)
        }
    }

    func configure(with item: EvaluationManifest.Suite.Case) {
        titleLabel.text = item.title

        let result = item.results.last?.outcome ?? .notDetermined
        activityIndicator.stopAnimating()
        statusIcon.isHidden = false

        switch result {
        case .pass:
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
            statusLabel.text = "Passed"
            statusLabel.textColor = .systemGreen
            contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        case .fail:
            statusIcon.image = UIImage(systemName: "xmark.circle.fill")
            statusIcon.tintColor = .systemRed
            statusLabel.text = "Failed"
            statusLabel.textColor = .systemRed
            contentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        case .processing:
            statusIcon.isHidden = true
            activityIndicator.startAnimating()
            statusLabel.text = "Running"
            statusLabel.textColor = .systemBlue
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        case .awaitingJudging:
            statusIcon.image = UIImage(systemName: "eye.fill")
            statusIcon.tintColor = .systemOrange
            statusLabel.text = "Judging"
            statusLabel.textColor = .systemOrange
            contentView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        case .notDetermined:
            statusIcon.image = UIImage(systemName: "circle.dotted")
            statusIcon.tintColor = .tertiaryLabel
            statusLabel.text = "Pending"
            statusLabel.textColor = .tertiaryLabel
            contentView.backgroundColor = .secondarySystemGroupedBackground
        }
    }
}

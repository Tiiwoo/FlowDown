//
//  EvaluationStatusCollectionView+Delegate.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import UIKit

extension EvaluationStatusCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let caseItem = caseItem(for: item) else { return }
        onSelectCase?(caseItem)
    }
}

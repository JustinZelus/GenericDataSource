//
//  DelegatedGeneralCollectionView.swift
//  GenericDataSource
//
//  Created by Mohamed Afifi on 3/20/16.
//  Copyright © 2016 mohamede1945. All rights reserved.
//

import UIKit

protocol GeneralCollectionViewMapping {
    
    func localSectionForGlobalSection(globalSection: Int) -> Int
    func globalSectionForLocalSection(localSection: Int) -> Int
    
    func localIndexPathForGlobalIndexPath(globalIndexPath: NSIndexPath) -> NSIndexPath
    
    func globalIndexPathForLocalIndexPath(localIndexPath: NSIndexPath) -> NSIndexPath
    
    var delegate: GeneralCollectionView? { get }
}

extension GeneralCollectionViewMapping {

    final func localIndexPathsForGlobalIndexPaths(globalIndexPaths: [NSIndexPath]) -> [NSIndexPath] {
        return globalIndexPaths.map(localIndexPathForGlobalIndexPath)
    }
    
    final func globalIndexPathsForLocalIndexPaths(localIndexPaths: [NSIndexPath]) -> [NSIndexPath] {
        return localIndexPaths.map(globalIndexPathForLocalIndexPath)
    }
    
    final func globalSectionSetForLocalSectionSet(localSections: NSIndexSet) -> NSIndexSet {
        
        let globalSections = NSMutableIndexSet()
        for section in localSections {
            let globalSection = globalSectionForLocalSection(section)
            globalSections.addIndex(globalSection)
        }
        return globalSections
    }
}

class DelegatedGeneralCollectionView: GeneralCollectionView {
    
    let mapping: GeneralCollectionViewMapping
    
    var delegate: GeneralCollectionView? {
        return mapping.delegate
    }

    init(mapping: GeneralCollectionViewMapping) {
        self.mapping = mapping
    }
    
    // MARK:- Register, dequeue
    
    func ds_registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        delegate?.ds_registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func ds_registerNib(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        delegate?.ds_registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func ds_dequeueReusableCellViewWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> ReusableCell {
        guard let delegate = delegate else {
            fatalError("Couldn't call \(__FUNCTION__) of \(self) with a nil delegate. This is usually because you didn't set your UITableView/UICollection to ds_reusableViewDelegate for the GenericDataSource.")
        }

        let globalIndexPath = ds_globalIndexPathForLocalIndexPath(indexPath)
        return delegate.ds_dequeueReusableCellViewWithIdentifier(identifier, forIndexPath: globalIndexPath)
    }

    // MARK:- Numbers
    
    func ds_numberOfSections() -> Int {
        guard let delegate = delegate else {
            fatalError("Couldn't call \(__FUNCTION__) of \(self) with a nil delegate. This is usually because you didn't set your UITableView/UICollection to ds_reusableViewDelegate for the GenericDataSource.")
        }
        return delegate.ds_numberOfSections()
    }
    
    func ds_numberOfItemsInSection(section: Int) -> Int {
        guard let delegate = delegate else {
            fatalError("Couldn't call \(__FUNCTION__) of \(self) with a nil delegate. This is usually because you didn't set your UITableView/UICollection to ds_reusableViewDelegate for the GenericDataSource.")
        }
        let globalSection = globalSectionForLocalSection(section)
        return delegate.ds_numberOfItemsInSection(globalSection)
    }
    
    // MARK:- Manpulate items and sections
    
    func ds_reloadData() {
        delegate?.ds_reloadData()
    }
    
    func ds_performBatchUpdates(updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        delegate?.ds_performBatchUpdates(updates, completion: completion)
    }
    
    func ds_insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        let globalSections = globalSectionSetForLocalSectionSet(sections)
        delegate?.ds_insertSections(globalSections, withRowAnimation: animation)
    }
    
    func ds_deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        let globalSections = globalSectionSetForLocalSectionSet(sections)
        delegate?.ds_deleteSections(globalSections, withRowAnimation: animation)
    }
    
    func ds_reloadSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        let globalSections = globalSectionSetForLocalSectionSet(sections)
        delegate?.ds_reloadSections(globalSections, withRowAnimation: animation)
    }
    
    func ds_moveSection(section: Int, toSection newSection: Int) {
        let globalSection = globalSectionForLocalSection(section)
        let globalNewSection = globalSectionForLocalSection(newSection)
        delegate?.ds_moveSection(globalSection, toSection: globalNewSection)
    }
    
    func ds_insertItemsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        let globalIndexPaths = globalIndexPathsForLocalIndexPaths(indexPaths)
        delegate?.ds_insertItemsAtIndexPaths(globalIndexPaths, withRowAnimation: animation)
    }
    
    func ds_deleteItemsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        let globalIndexPaths = globalIndexPathsForLocalIndexPaths(indexPaths)
        delegate?.ds_deleteItemsAtIndexPaths(globalIndexPaths, withRowAnimation: animation)
    }
    
    func ds_reloadItemsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        let globalIndexPaths = globalIndexPathsForLocalIndexPaths(indexPaths)
        delegate?.ds_reloadItemsAtIndexPaths(globalIndexPaths, withRowAnimation: animation)
    }
    
    func ds_moveItemAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        let globalIndexPath = ds_globalIndexPathForLocalIndexPath(indexPath)
        let globalNewIndexPath = ds_globalIndexPathForLocalIndexPath(indexPath)
        
        delegate?.ds_moveItemAtIndexPath(globalIndexPath, toIndexPath: globalNewIndexPath)
    }
    
    // MARK:- Scroll
    
    func ds_scrollToItemAtIndexPath(indexPath: NSIndexPath, atScrollPosition scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        let globalIndexPath = ds_globalIndexPathForLocalIndexPath(indexPath)
        delegate?.ds_scrollToItemAtIndexPath(globalIndexPath, atScrollPosition: scrollPosition, animated: animated)
    }

    // MARK:- Select/Deselect
    
    func ds_selectItemAtIndexPath(indexPath: NSIndexPath?, animated: Bool, scrollPosition: UICollectionViewScrollPosition) {
        let globalIndexPath: NSIndexPath?
        if let indexPath = indexPath {
            globalIndexPath = ds_globalIndexPathForLocalIndexPath(indexPath)
        } else {
            globalIndexPath = nil
        }
        
        delegate?.ds_selectItemAtIndexPath(globalIndexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func ds_deselectItemAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
        let globalIndexPath = ds_globalIndexPathForLocalIndexPath(indexPath)
        delegate?.ds_deselectItemAtIndexPath(globalIndexPath, animated: animated)
    }
    
    // MARK:- IndexPaths, Cells
    
    func ds_indexPathForCell(cell: ReusableCell) -> NSIndexPath? {
        if let indexPath = delegate?.ds_indexPathForCell(cell) {
            return ds_localIndexPathForGlobalIndexPath(indexPath)
        }
        return nil
    }
    
    func ds_indexPathForItemAtPoint(point: CGPoint) -> NSIndexPath? {
        if let indexPath = delegate?.ds_indexPathForItemAtPoint(point) {
            return ds_localIndexPathForGlobalIndexPath(indexPath)
        }
        return nil
    }
    
    func ds_indexPathsForVisibleItems() -> [NSIndexPath] {
        if let indexPaths = delegate?.ds_indexPathsForVisibleItems() {
            return localIndexPathsForGlobalIndexPaths(indexPaths) ?? []
        }
        return []
    }
    
    func ds_indexPathesForSelectedItems() -> [NSIndexPath] {
        if let indexPaths = delegate?.ds_indexPathesForSelectedItems() {
            return localIndexPathsForGlobalIndexPaths(indexPaths) ?? []
        }
        return []
    }
    
    func ds_visibleCells() -> [ReusableCell] {
        return delegate?.ds_visibleCells() ?? []
    }
    
    func ds_cellForItemAtIndexPath(indexPath: NSIndexPath) -> ReusableCell? {
        let globalIndexPath = ds_globalIndexPathForLocalIndexPath(indexPath)
        return delegate?.ds_cellForItemAtIndexPath(globalIndexPath)
    }
    
    // MARK:- Scroll View
    
    var ds_scrollView: UIScrollView {
        guard let delegate = delegate else {
            fatalError("Couldn't call \(__FUNCTION__) of \(self) with a nil delegate. This is usually because you didn't set your UITableView/UICollection to ds_reusableViewDelegate for the GenericDataSource.")
        }
        return delegate.ds_scrollView
    }

    // MARK:- Private

    func ds_localIndexPathForGlobalIndexPath(globalIndexPath: NSIndexPath) -> NSIndexPath {
        return mapping.localIndexPathForGlobalIndexPath(globalIndexPath)
    }

    private func localIndexPathsForGlobalIndexPaths(globalIndexPaths: [NSIndexPath]) -> [NSIndexPath] {
        return mapping.localIndexPathsForGlobalIndexPaths(globalIndexPaths)
    }

    func ds_globalIndexPathForLocalIndexPath(localIndexPath: NSIndexPath) -> NSIndexPath {
        return mapping.globalIndexPathForLocalIndexPath(localIndexPath)
    }

    private func globalIndexPathsForLocalIndexPaths(localIndexPaths: [NSIndexPath]) -> [NSIndexPath] {
        return mapping.globalIndexPathsForLocalIndexPaths(localIndexPaths)
    }

    private func globalSectionForLocalSection(localSection: Int) -> Int {
        return mapping.globalSectionForLocalSection(localSection)
    }

    private func globalSectionSetForLocalSectionSet(localSections: NSIndexSet) -> NSIndexSet {
        return mapping.globalSectionSetForLocalSectionSet(localSections)
    }
}
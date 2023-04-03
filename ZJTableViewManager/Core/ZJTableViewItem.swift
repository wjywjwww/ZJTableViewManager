//
//  ZJTableViewItem.swift
//  NewRetail
//
//  Created by Javen on 2018/2/8.
//  Copyright © 2018年 . All rights reserved.
//

import UIKit

public typealias ZJTableViewItemBlock = (ZJTableViewItem) -> Void

open class ZJTableViewItem: NSObject {
    public var tableVManager: ZJTableViewManager? {
        return section?.tableViewManager
    }

    private weak var _section: ZJTableViewSection?
    public var section: ZJTableViewSection? {
        set {
            _section = newValue
        }
        get {
            return _section
        }
    }

    public var cellIdentifier: String!
    /// cell高度(如果要自动计算高度，使用autoHeight(manager:)方法，框架会算出高度，具体看demo)
    /// 传UITableViewAutomaticDimension则是系统实时计算高度，可能会有卡顿、reload弹跳等问题，不建议使用，有特殊需要可以选择使用
    public var cellHeight: CGFloat!
    /// cell点击事件的回调
    public var selectionHandler: ZJTableViewItemBlock?
    public func setSelectionHandler<T: ZJTableViewItem>(_ handler: ((_ callBackItem: T) -> Void)?) {
        selectionHandler = { item in
            handler?(item as! T)
        }
    }

    public var deletionHandler: ZJTableViewItemBlock?
    public func setDeletionHandler<T: ZJTableViewItem>(_ handler: ((_ callBackItem: T) -> Void)?) {
        deletionHandler = { item in
            handler?(item as! T)
        }
    }

    public var labelText: String?
    public var detailLabelText: String?
    public var textAlignment: NSTextAlignment = .left
    public var detailTextAlignment: NSTextAlignment = .left
    public var image: UIImage?
    public var highlightedImage: UIImage?
    public var style: UITableViewCell.CellStyle = .default
    public var accessoryType: UITableViewCell.AccessoryType = .none
    public var selectionStyle: UITableViewCell.SelectionStyle = .default
    public var editingStyle: UITableViewCell.EditingStyle = .none
    public var canEdit:Bool = true
    public var accessoryView: UIView?
    public var isSelected: Bool {
        return cell?.isSelected ?? false
    }
    public var isAllowSelect: Bool = true

    public var indexPath: IndexPath? {
        if let section = self.section,
           let rowIndex = self.section?.items.zj_indexOf(self),
           let section = self.tableVManager?.sections.zj_indexOf(section){
            return IndexPath(item: rowIndex, section: section)
        } else {
            return nil
        }
    }

    public var cell: UITableViewCell? {
        if let indexPath = indexPath {
            return tableVManager?.tableView.cellForRow(at: indexPath)
        } else {
            return nil
        }
    }

    override public init() {
        super.init()
        cellIdentifier = "\(type(of: self))"
        cellHeight = 44
    }

    public convenience init(text: String?) {
        self.init()
        labelText = text
    }

    public func reload(_ animation: UITableView.RowAnimation) {
        if let indexPath = indexPath,
           let tableVManager = tableVManager{
            zj_log("reload tableview at \(indexPath)")
            tableVManager.tableView.beginUpdates()
            tableVManager.tableView.reloadRows(at: [indexPath], with: animation)
            tableVManager.tableView.endUpdates()
        }
    }

    public func select(animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none) {
        if let tableVManager = tableVManager {
            if isAllowSelect {
                tableVManager.tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
            }
        }
    }

    public func deselect(animated: Bool = true) {
        if let indexPath = indexPath,
           let tableVManager = tableVManager{
            tableVManager.tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    public func delete(_ animation: UITableView.RowAnimation = .automatic) {
        if let indexPath = indexPath,
           let section = section,
           let tableVManager = tableVManager{
            if !section.items.contains(where: { $0 == self }) {
                zj_log("can't delete because this item did not in section")
                return
            }
            section.items.remove(at: indexPath.row)
            tableVManager.tableView.deleteRows(at: [indexPath], with: animation)
        }
        
    }

    /// 计算cell高度
    ///
    /// - Parameters:
    ///   - manager: 当前tableview的manager
    public func autoHeight(_ manager: ZJTableViewManager) {
        guard let cell = manager.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ZJInternalCellProtocol else {
            zj_log("please register cell")
            return
        }

        cell._item = self
        cell.cellPrepared()
        cellHeight = cell.systemLayoutSizeFitting(CGSize(width: manager.tableView.frame.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
    }
}

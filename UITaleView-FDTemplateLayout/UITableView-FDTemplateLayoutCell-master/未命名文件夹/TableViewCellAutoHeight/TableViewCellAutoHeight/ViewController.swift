//
//  ViewController.swift
//  TableViewCellAutoHeight
//
//  Created by shuo on 2017/4/21.
//  Copyright © 2017年 shuo. All rights reserved.
//

import UIKit
import UITableView_FDTemplateLayoutCell
import Masonry


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let dataSource: [String] = ["CELL高度自适应", "这是一条很长的内容，这是一条很长的内容，这是一条很长的内容， 这是一条很长的内容， 这是一条很长的内容， 这是一条很长的内容， 这是一条很长的内容！！！"]
    
    let identifier = String(describing: SimpleTextTableViewCell.self)
    /**
     当使用tableView来自于storyboard的时候，首次获取到的tableView.frame等于其所在sb中的大小，而不是根据实际手机尺寸获取到的大小
     tableView 代理方法执行顺序为：
     1. estimatedHeightForRowAt
     2. cellForRowAt
     3. heightForRowAt
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        
        tableView.tableFooterView = UIView()
        
        //tableView.estimatedRowHeight = 44.0
        //tableView.rowHeight = UITableViewAutomaticDimension
    }


}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SimpleTextTableViewCell
        cell?.detailLabel.text = dataSource[indexPath.row]
        return cell!
    }
    
}

extension ViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 44
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: identifier) { (cell) in
            let simpleCell = cell as! SimpleTextTableViewCell
            simpleCell.bounds.size.width = tableView.bounds.width
            simpleCell.detailLabel.text = self.dataSource[indexPath.row]
        }
    }
    
}

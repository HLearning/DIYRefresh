//
//  MenuViewController.swift
//  DIYRefresh
//
//  Created by SunnyMac on 16/11/28.
//  Copyright © 2016年 hjl. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    var names: [String] = ["SINA", "MI", "AKTA"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DIYRefresh"
        self.view.backgroundColor = UIColor.white
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.names.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        }
        cell?.textLabel?.text = "测试数据-----" + "\(names[indexPath.row])"
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = ContentViewController()
        vc.name = names[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

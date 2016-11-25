//
//  ContentViewController.swift
//  DIYRefresh
//
//  Created by SunnyMac on 16/11/23.
//  Copyright © 2016年 hjl. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    var data: [Int] = [1001,1]
    
    var indexHeader : Int = 100
    
    lazy var tableView : UITableView = {
        let tableView : UITableView = UITableView.init(frame: self.view.bounds, style: .plain)
        //let tableView : UITableView = UITableView.init(frame: CGRect.init(x: 0, y: 100, width: 325, height: 400), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = true
        return tableView
    }()

    var diyRefresh : DIYRefreshView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
//        self.diyRefresh = DIYRefreshView.attach(scrollView: self.tableView, plist: "AKTA",target: self, refreshAction: #selector(finishRefreshControl),  color: .red,  finishedCallback: {
//            
//            self.finishRefreshControl()
//            self.diyRefresh!.finishingLoading()
//        })
        
        self.diyRefresh = DIYRefreshView.attach(scrollView: self.tableView, plist: "A",target: self, refreshAction: #selector(finishRefreshControl), color: UIColor.blue, lineWidth: 5, finishedCallback: nil)
  
    }
    
    // 完成刷新控制
    func finishRefreshControl() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            /// 添加数据
            self.indexHeader -= 1
            self.data.insert(self.indexHeader, at: 0)
            self.tableView.reloadData()
            
            self.diyRefresh!.finishingLoading()
        }
    }
}

extension ContentViewController {
    func setupUI() {
        self.title = "DIYRefresh"
        self.view.backgroundColor = UIColor.white
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        self.view.addSubview(tableView)
    }
}

extension ContentViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        }
        cell?.textLabel?.text = "测试数据-----" + "\(data[indexPath.row])"
        
        return cell!
    }
}










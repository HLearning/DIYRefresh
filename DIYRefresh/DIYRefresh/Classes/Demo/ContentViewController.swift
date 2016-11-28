//
//  ContentViewController.swift
//  DIYRefresh
//
//  Created by SunnyMac on 16/11/23.
//  Copyright © 2016年 hjl. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    var data: [Int] = [100]
    
    var indexHeader : Int = 100
    
    var name : String = ""
    
    lazy var tableView : UITableView = {
        let tableView : UITableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = true
        return tableView
    }()

    var diyRefresh : DIYRefreshView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        // 方式1:
        //self.diyRefresh = DIYRefreshView.attach(scrollView: self.tableView, plist: self.name, target: self, refreshAction: #selector(finishRefreshControl), color: .red)
        
        // 方式2:
//        self.diyRefresh = DIYRefreshView.attach(scrollView: self.tableView, plist: self.name, color: .red, finishedCallback: {
//            self.finishRefreshControl()
//        })
        
        self.diyRefresh = DIYRefreshView.attach(scrollView: self.tableView, plist: self.name, target: self, refreshAction: #selector(finishRefreshControl), color: .orange, lineWidth: 5, dropHeight: 80, scale: 1, showStyle: 0, horizontalRandomness: 300, isReverseLoadingAnimation: false, finishedCallback: {
            
        })
        
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
        self.title = self.name
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
        cell?.textLabel?.text = self.name + "----->" + "\(data[indexPath.row])"
        
        return cell!
    }
}










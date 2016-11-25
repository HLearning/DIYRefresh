//
//  DIYRefreshView.swift
//  DIYRefresh
//
//  Created by SunnyMac on 16/11/23.
//  Copyright © 2016年 hjl. All rights reserved.
//

import UIKit
// 单条线颜色的停留时间
let kloadingIndividualAnimationTiming : CGFloat = 1
// 透明度
let kbarDarkAlpha : CGFloat = 0.4
// 偏移时间, 也就是刷新时动画的单位时间
let kloadingTimingOffset : CGFloat = 0.1
// 消失的时间
let kdisappearDuration : CGFloat = 0.8
// 相对高度
let krelativeHeightFactor : CGFloat = 2.0/5

let startPointKey = "startPoints"
let endPointKey = "endPoints"

let kDIYRefreshContentOffset = "contentOffset"

enum DIYRefreshState {
    case normal
    case refreshing
    case disappearing
}
class DIYRefreshView: UIView {
    var state : DIYRefreshState = .normal
    var barItems : [DIYBarItem] = [DIYBarItem]()
    
    var scrollView : UIScrollView?
    var displayLink : CADisplayLink?
    var target : AnyObject?
    var action : Selector?
    var finishedCallback : (() -> ())?
    
    var lineCount : Int = 0
    
    // 显示风格: 0:飞来, 1: 淡入淡出
    var showStyle: Int = 0
    // 下拉的高度
    var dropHeight : CGFloat = 0.0
    // 原本的ContentInsetTop
    var originalContentInsetTop : CGFloat = 0.0
    // 消失的进度
    var disappearProgress : CGFloat = 0.0
    // 内部动画因素
    var internalAnimationFactor : CGFloat = 0.0
    // 水平随机数
    var horizontalRandomness : Int = 0
    // 反向加载动画
    var isReverseLoadingAnimation : Bool = false
    // 刷新时间
    var refreshTime : CGFloat = 0
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        /// 为scrollView的contentOffset属性, 添加一个监听者
        newSuperview?.addObserver(self, forKeyPath: kDIYRefreshContentOffset, options: .new, context: nil)
        /// 保存父控件, 都还是原始值, 此时scrollView还没有自动偏移
        scrollView = newSuperview as? UIScrollView
        scrollView?.autoresizesSubviews = false
    }
    
    // 监听UIScrollView的contentOffset属性
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (kDIYRefreshContentOffset == keyPath) {
            self.adjustStateWithContentOffset()
        }
    }
}

extension DIYRefreshView {
    class func attach(scrollView: UIScrollView,
                           plist: String,
                          target: AnyObject,
                   refreshAction: Selector,
                           color: UIColor)
        -> DIYRefreshView {
            
            return self.attach(scrollView: scrollView, plist: plist, target: target, refreshAction: refreshAction, color: color, lineWidth: 5, dropHeight: 80, scale: 0.8, showStyle: 0, horizontalRandomness: 150, isReverseLoadingAnimation: false, internalAnimationFactor: 0.7, finishedCallback: nil)
    }

    class func attach(scrollView: UIScrollView,
                      plist: String,
                      color: UIColor,
                      finishedCallback: (() -> ())?
        ) -> DIYRefreshView {
        
        return self.attach(scrollView: scrollView, plist: plist, target: nil, refreshAction: nil, color: color, lineWidth: 5, dropHeight: 80, scale: 0.8, showStyle: 0, horizontalRandomness: 150, isReverseLoadingAnimation: false, internalAnimationFactor: 0.7, finishedCallback: finishedCallback)
    }
    
    /// 刷新控件的创建方式
    class func attach(scrollView: UIScrollView,
                    plist: String,
                    target: AnyObject?,
                    refreshAction: Selector?,
                    color: UIColor = .red,
                    lineWidth: CGFloat = 5,
                    dropHeight: CGFloat = 80,
                    scale: CGFloat = 0.8,
                    showStyle: Int = 0,
                    horizontalRandomness: CGFloat = 150,
                    isReverseLoadingAnimation: Bool = false,
                    internalAnimationFactor: CGFloat = 0.7,
                    finishedCallback: (() -> ())?
        ) -> DIYRefreshView {
        /// 创建
        let diyRefresh = DIYRefreshView()
        /// 下降的高度
        diyRefresh.dropHeight = dropHeight
        /// 水平随机数
        diyRefresh.horizontalRandomness = Int(horizontalRandomness)
        /// 滚动视图
        diyRefresh.scrollView = scrollView
        /// 事件
        diyRefresh.target = target as AnyObject?
        /// 刷新事件
        diyRefresh.action = refreshAction
        /// 显示风格
        diyRefresh.showStyle = showStyle
        /// 反向加载动画
        diyRefresh.isReverseLoadingAnimation = isReverseLoadingAnimation
        /// 内部动画因素
        diyRefresh.internalAnimationFactor = internalAnimationFactor
        
        diyRefresh.finishedCallback = finishedCallback
        
        
        /// 添加控件
        scrollView.addSubview(diyRefresh)
        
        // 根据坐标点的最大h和最大y, 来计算框架
        var width : CGFloat = 0
        var height : CGFloat = 0
        
        /// 字典数据, plist 转 字典
        let str = Bundle.main.path(forResource: plist, ofType: "plist")
        let rootDictionary : NSMutableDictionary = NSMutableDictionary.init(contentsOfFile: str!)!
        
        /// 开始的数组
        var startPoints : [String] = rootDictionary.object(forKey: startPointKey) as! [String]
        /// 结束的数组
        var endPoints : [String] = rootDictionary.object(forKey: endPointKey) as! [String]
        
        /// 线条的个数
        diyRefresh.lineCount = startPoints.count
        
        /// 刷新的时间
        diyRefresh.refreshTime = CGFloat(diyRefresh.lineCount) * kloadingTimingOffset * 2
        
        /// 遍历, 求出最大的h和最大的w
        for i in 0 ..< startPoints.count {
            let startPoint : CGPoint = CGPointFromString(startPoints[i])
            let endPoint : CGPoint = CGPointFromString(endPoints[i])
            
            if startPoint.x > width {width = startPoint.x}
            if endPoint.x > width {width = endPoint.x}
            if startPoint.y > height {height = startPoint.y}
            if endPoint.y > height {height = endPoint.y}
        }
        /// 确定fream
        diyRefresh.frame = CGRect.init(x: 0, y: 0, width: width, height: height)

        // 创建items
        var mutableBarItems : [DIYBarItem] = [DIYBarItem]()
        
        for i in 0 ..< startPoints.count {
            let startPoint : CGPoint = CGPointFromString(startPoints[i])
            let endPoint : CGPoint = CGPointFromString(endPoints[i])
            
            // 创建barItem
            let barItem : DIYBarItem = DIYBarItem.init(frame: diyRefresh.frame, startPoint: startPoint, endPoint: endPoint, color: color, lineWidth: lineWidth)
            // tag标示
            barItem.tag = i
            // 无背景色
            barItem.backgroundColor = UIColor.clear
            // 透明度
            barItem.alpha = 0
            // 添加到数组
            mutableBarItems.append(barItem)
            // 添加到刷新控件里面
            diyRefresh.addSubview(barItem)

            // 设置barItem
            barItem.setHorizontalRandomness(horizontalRandomness: diyRefresh.horizontalRandomness, dropHeight: diyRefresh.dropHeight)
        }

        // barItems
        diyRefresh.barItems = mutableBarItems
        // 控件的fream
        diyRefresh.frame = CGRect.init(x: 0, y: 0, width: width, height: height)

        diyRefresh.center = CGPoint.init(x: scrollView.frame.size.width / 2 , y: 0)

        //
        for barItem in diyRefresh.barItems {
            barItem.setupWithFrame(rect: diyRefresh.frame)
        }
        
        // 默认动画时的缩放比例
        diyRefresh.transform = CGAffineTransform.init(scaleX: scale, y: scale * 1)
        
        return diyRefresh
    }
}

extension DIYRefreshView{
    // 偏移量和内边距抵消后, 真正的偏移量
    func realContentOffsetY() -> CGFloat {
        return self.scrollView!.contentOffset.y + self.originalContentInsetTop;
    }
    
    // 动画的进度
    func animationProgress() -> CGFloat {
        
        let x = fabsf(Float(self.realContentOffsetY()))
        
        let y = max(Double(0), Double(x / Float(self.dropHeight)))
        
        return CGFloat(min(1.0, y))
    }
    
    /// 开始加载动画
    func startLoadingAnimation() {

        /// 反向加载动画
        if (self.isReverseLoadingAnimation) {
            let count : Int = self.barItems.count
            for j in 0 ..< (self.barItems).count {
                let i = count - j - 1
                let barItem = self.barItems[i]
                
                self.perform(#selector(barItemAnimation), with: barItem, afterDelay: TimeInterval(CGFloat(i) * kloadingTimingOffset), inModes: [.commonModes])
            }
        }/// 正向加载动画
        else {
            for i in 0 ..< self.barItems.count {

                let barItem = self.barItems[i]
                
                // 单线程的函数, 他会在主函数: startLoadingAnimation 执行完, 才开始调用方法: barItemAnimation
                self.perform(#selector(barItemAnimation), with: barItem, afterDelay: TimeInterval(CGFloat(i ) * kloadingTimingOffset), inModes: [.commonModes])
            }
        }
    }
    
    // baritem的动画
    func barItemAnimation(barItem: DIYBarItem) {
        // 正在刷新中...
        if self.state == DIYRefreshState.refreshing {
            // 不透明
            barItem.alpha = 1
            // 移除动画
            barItem.layer.removeAllAnimations()
            // 定时将线条的颜色还原
            UIView.animate(withDuration: TimeInterval(kloadingIndividualAnimationTiming), animations: {
                barItem.alpha = kbarDarkAlpha
            })

            var isLastOne = true
            // 如果反向加载, 最后一个是0
            if self.isReverseLoadingAnimation {
                isLastOne = barItem.tag == 0
            } else {
                // 如果正向加载, 最后一个是count - 1;
                isLastOne = barItem.tag == self.barItems.count - 1
                // 如果是最后一个, 并且正在刷新中, 可以执行第二遍动画
                if isLastOne && self.state == DIYRefreshState.refreshing {
                    // 开始第二遍动画, 递归,无出口, 形成死循环, 会一直刷新
                    // 不延时的话, 下一遍的第一个线段 会和 上一次的最后一个线段, 同时显示
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(kloadingTimingOffset)) {
                        self.startLoadingAnimation()
                    }
                }
            }
        }
    }
    
    // 更新消失动画
    func updateDisappearAnimation() {
        
        if self.disappearProgress >= 0 && self.disappearProgress <= 1 {
            // iOS设备的刷新频率事60HZ也就是每秒60次。那么每一次刷新的时间就是1/60秒 大概16.7毫秒
            self.disappearProgress -= 1.0/60.0/kdisappearDuration
            
            self.updateBarItems(progress: self.disappearProgress)
        }
    }
    
    //
    func updateBarItems(progress: CGFloat) {
        for (index,barItem) in (self.barItems).enumerated() {
            let startPadding : CGFloat = (1.0 - self.internalAnimationFactor) / CGFloat(self.barItems.count) * CGFloat(index)
            let endPadding : CGFloat = 1 - self.internalAnimationFactor - startPadding
            
            if (progress == 1 || progress >= 1 - endPadding) {
                barItem.transform = CGAffineTransform.identity
                barItem.alpha = kbarDarkAlpha
            }else if (progress == 0) {
                barItem.setHorizontalRandomness(horizontalRandomness: self.horizontalRandomness, dropHeight: self.dropHeight)
            }else {
                var realProgress : CGFloat = 0
                if (progress <= startPadding){
                    realProgress = 0
                }
                else {
                    realProgress = CGFloat(min(1.0,(progress - startPadding)/self.internalAnimationFactor))
                    
                    /// 飞来的风格
                    if self.showStyle == 0 {
                        barItem.transform = CGAffineTransform.init(translationX: barItem.translationX*(1-realProgress), y: -self.dropHeight*(1-realProgress))
                    }
                    
                    barItem.alpha = realProgress * kbarDarkAlpha
                }
            }
        }
    }
    
    // 完成加载
    func finishingLoading() {
        // 状态设置为: 消失
        self.state = DIYRefreshState.disappearing
        
        // 花费0.8秒来还原scrollview的contentInset
        UIView.animate(withDuration: TimeInterval(kdisappearDuration), animations: {
            self.scrollView?.contentInset.top = self.originalContentInsetTop
        }) { (Bool) in
            // 状态设置为:正常
            self.state = DIYRefreshState.normal
            self.displayLink?.invalidate()
            self.disappearProgress = 1
        }
        
        // 所有的动画都移除, 并且颜色都还原
        for barItem in self.barItems {
            barItem.layer.removeAllAnimations()
            barItem.alpha = kbarDarkAlpha
        }
        
        self.displayLink = CADisplayLink.init(target: self, selector: #selector(updateDisappearAnimation))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        self.disappearProgress = 1
    }
}

extension DIYRefreshView : UIScrollViewDelegate{
    
    func adjustStateWithContentOffset(){
        self.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2, y: self.realContentOffsetY() * krelativeHeightFactor)
        // 如果正在拖动
        if (self.scrollView?.isDragging)! {
            
            if self.originalContentInsetTop == 0 {
                self.originalContentInsetTop = (self.scrollView?.contentInset.top)!
            }

            if self.state == DIYRefreshState.normal {
                self.updateBarItems(progress: self.animationProgress())
            }
        }// 手松开
        else{
            // 松手就会刷新的状态
            if (self.state == DIYRefreshState.normal && self.realContentOffsetY() < -self.dropHeight) {
                if (self.animationProgress() == CGFloat(1)) {
                    self.state = DIYRefreshState.refreshing
                }
                if (self.state == DIYRefreshState.refreshing) {
                    
                    var newInsets : UIEdgeInsets = self.scrollView!.contentInset
                    
                    newInsets.top = self.originalContentInsetTop + self.dropHeight
                    
                    let contentOffset : CGPoint = self.scrollView!.contentOffset
                    
                    UIView.animate(withDuration: 0, animations: {
                        self.scrollView?.contentInset = newInsets
                        self.scrollView?.contentOffset = contentOffset
                    })
                    
                    if (self.target?.responds(to: self.action))! {
                        self.target?.perform(self.action!, with: nil, afterDelay: TimeInterval(self.refreshTime), inModes: [RunLoopMode.commonModes])
                    }
                    
                    if ((self.finishedCallback) != nil) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(self.refreshTime)) {
                            self.finishedCallback!()
                        }
                    }
                    // 开始第一遍动画
                    self.startLoadingAnimation()
                }
            } else{
                // 还原成最初的设置
                self.updateBarItems(progress: self.animationProgress())
            }
        }
    }
}


















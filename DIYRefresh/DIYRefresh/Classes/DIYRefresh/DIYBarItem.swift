//
//  DIYBarItem.swift
//  DIYRefresh
//
//  Created by SunnyMac on 16/11/23.
//  Copyright © 2016年 hjl. All rights reserved.
//

import UIKit

class DIYBarItem: UIView {

    /// 中间点坐标
    var middlePoint : CGPoint
    /// 宽度
    var lineWidth : CGFloat
    /// 开始坐标
    var startPoint : CGPoint
    /// 结束坐标
    var endPoint: CGPoint
    /// 颜色
    var color : UIColor
    /// x轴的平移
    var translationX : CGFloat = 0
    
    init(frame: CGRect, startPoint: CGPoint, endPoint: CGPoint, color: UIColor, lineWidth: CGFloat) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.lineWidth = lineWidth
        self.color = color
        /// 中心点坐标
        self.middlePoint = CGPoint.init(x: (startPoint.x + endPoint.x)/2, y: (startPoint.y + endPoint.y)/2)
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 自调用
    override func draw(_ rect: CGRect) {
        //print("draw...")
        /// 贝塞尔曲线
        let bezierPath : UIBezierPath = UIBezierPath()
        /// 设置初始线段的起点
        bezierPath.move(to: self.startPoint)
        /// 创建从起点到终点的线
        bezierPath.addLine(to: self.endPoint)
        /// 设置边框颜色
        self.color.setStroke()
        /// 线段宽度
        bezierPath.lineWidth = self.lineWidth
        /// 根据坐标点连线
        bezierPath.stroke()
    }

}

extension DIYBarItem {
    
    
    func setupWithFrame(rect : CGRect) {
        //print("setupWithFrame")
        /// 图像变化时的锚点
        self.layer.anchorPoint = CGPoint.init(x: self.middlePoint.x/self.frame.size.width, y: self.middlePoint.y/self.frame.size.height)
        ///
        self.frame = CGRect.init(x: self.frame.origin.x + self.middlePoint.x - self.frame.size.width/2, y: self.frame.origin.y + self.middlePoint.y - self.frame.size.height/2, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    func setHorizontalRandomness(horizontalRandomness: Int, dropHeight: CGFloat) {
        /// 产生一个随机值
        let randomNumber : Int = Int(arc4random() % UInt32(horizontalRandomness) * 2) - horizontalRandomness

        ///
        self.translationX = CGFloat(randomNumber)
        /// 
        self.transform = CGAffineTransform.init(translationX: self.translationX, y: -dropHeight)
    }

}

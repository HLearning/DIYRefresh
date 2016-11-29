//
//  DIYBarItem.swift
//  DIYRefresh
//
//  Created by SunnyMac on 16/11/23.
//  Copyright © 2016年 hjl. All rights reserved.
//

import UIKit

class DIYBarItem: UIView {

    var middlePoint : CGPoint
    var lineWidth : CGFloat
    var startPoint : CGPoint
    var endPoint: CGPoint
    var color : UIColor
    var translationX : CGFloat = 0
    
    init(frame: CGRect, startPoint: CGPoint, endPoint: CGPoint, color: UIColor, lineWidth: CGFloat) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.lineWidth = lineWidth
        self.color = color
        self.middlePoint = CGPoint.init(x: (startPoint.x + endPoint.x)/2, y: (startPoint.y + endPoint.y)/2)
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        /// 贝塞尔曲线
        let bezierPath : UIBezierPath = UIBezierPath()
        bezierPath.move(to: self.startPoint)
        bezierPath.addLine(to: self.endPoint)
        self.color.setStroke()
        bezierPath.lineWidth = self.lineWidth
        bezierPath.stroke()
    }
}

extension DIYBarItem {
    
    func setupWithFrame(rect : CGRect) {
        /// 图像变化时的锚点
        self.layer.anchorPoint = CGPoint.init(x: self.middlePoint.x/self.frame.size.width, y: self.middlePoint.y/self.frame.size.height)
        
        self.frame = CGRect.init(x: self.frame.origin.x + self.middlePoint.x - self.frame.size.width/2, y: self.frame.origin.y + self.middlePoint.y - self.frame.size.height/2, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    func setHorizontalRandomness(horizontalRandomness: Int, dropHeight: CGFloat) {
        /// 产生一个随机值
        let randomNumber : Int = Int(arc4random() % UInt32(horizontalRandomness) * 2) - horizontalRandomness
        self.translationX = CGFloat(randomNumber)
        self.transform = CGAffineTransform.init(translationX: self.translationX, y: -dropHeight)
    }

}

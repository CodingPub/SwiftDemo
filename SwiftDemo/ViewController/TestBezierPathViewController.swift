//
//  TestBezierPathViewController.swift
//  SwiftDemo
//
//  Created by XiaobinLin on 2019/11/8.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class TestBezierPathViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.setNavigationBarHidden(true, animated: true)

        // 画椭圆，在给定矩形区域中画椭圆，正方形就是圆 长方形就是椭圆
        let path = UIBezierPath(ovalIn: CGRect(x: 10, y: 30, width: 200, height: 100))
        path.lineWidth = 1
        path.stroke()
        
        let pathlayer = CAShapeLayer()
        pathlayer.strokeColor = UIColor.red.cgColor
        pathlayer.path = path.cgPath
        pathlayer.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(pathlayer)
    
        
        /*
           roundedRect: 画的区域
           byRoundingCorners: 枚举，四个角实行圆角的哪个位置
           cornerRadii: 圆角大小
        */
        
        let path1 = UIBezierPath(roundedRect: CGRect(x: 250, y: 30, width: 100, height: 100), byRoundingCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize(width: 50, height: 50))
        let pathlayer1 = CAShapeLayer()
        pathlayer1.strokeColor = UIColor.red.cgColor
        pathlayer1.path = path1.cgPath
        pathlayer1.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(pathlayer1)

        
        // 也是画圆角形状，和上边的区别是四个角全部为圆角
        let path2 = UIBezierPath(roundedRect: CGRect(x: 130, y: 150, width: 100, height: 100), cornerRadius: 20)
        self.createlayer(path: path2)
        
        
        
        // 划三角形, 五角星  都能画出来了吧，根据点来连线就行了
        let path3 = UIBezierPath()
        path3.move(to: CGPoint(x: 60, y: 150))
        path3.addLine(to: CGPoint(x: 10, y: 235))
        path3.addLine(to: CGPoint(x: 110, y: 235))
        path3.close()
        self.createlayer(path: path3)
        
        /*
           画狐线,顺时针画弧线，从 startAngle 顺时针画到 endAngle
           arcCenter： 弧度的中心点
           radius： 半径
           startAngle： 开始的角度
           endAngle： 结束的角度
        */
        let path4 = UIBezierPath(arcCenter:  CGPoint(x: 280, y: 200), radius: 50, startAngle: 0, endAngle: CGFloat.pi / 180 * 135, clockwise: false)
        path4.close()
    
        self.createlayer(path: path4)
        
        
        /*
            画S 弧线，严格的来说不能说是 S 弧线，因为有两个控制点。控制点在一侧，就是一种曲线，在两侧就是 S 线。
            move： 添加一个起点
            to： 终点
            controlPoint1： 第一个控制点
            controlPoint2： 第二个控制点
            控制点是拉伸起点和终点画出的这条直线的弯曲方向，弯曲的高度是控制点到直线距离的一半
        */
        
        let path5 = UIBezierPath()
        path5.move(to: CGPoint(x: 20, y: 300))
        path5.addCurve(to: CGPoint(x: 220, y: 300), controlPoint1: CGPoint(x: 70, y: 280), controlPoint2: CGPoint(x: 170, y: 350))
        
        self.createlayer(path: path5)
        
        // 画弧线 和上边原理一样  但是只有一个控制点
        let path6 = UIBezierPath()
        path6.move(to: CGPoint(x: 20, y: 400))
        path6.addQuadCurve(to: CGPoint(x: 200, y: 400), controlPoint: CGPoint(x: 100, y: 450))
        self.createlayer(path: path6)
        
        // 进度圆角矩形
        let progressView = RoundProgressView(frame: CGRect(x: 20, y: 460, width: 80, height: 80))
        progressView.progress = 0.5
        progressView.borderColor = UIColor.orange
        progressView.cornerRadius = 6;
        progressView.borderWidth = 2
        self.view.addSubview(progressView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            progressView.progress = 0.8
        }
    }
    
    func createlayer(path: UIBezierPath) {
        let pathlayer1 = CAShapeLayer()
        // 画的线的颜色
        pathlayer1.strokeColor = UIColor.green.cgColor
        // 划线的宽度
        pathlayer1.path = path.cgPath
        // 填充色
        pathlayer1.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(pathlayer1)
    }
}


class RoundProgressView : UIView {
    var cornerRadius: CGFloat = 0 {
        didSet {
            recreateLayers()
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            recreateLayers()
        }
    }
    
    var borderColor: UIColor = UIColor.black {
        didSet {
            recreateLayers()
        }
    }
    
    var borderWidth: CGFloat = 0 {
        didSet {
            recreateLayers()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override var frame: CGRect {
        didSet {
            recreateLayers()
        }
    }
    
    override func didMoveToSuperview() {
        recreateLayers()
    }
    
    private func recreateLayers() {
        guard let _ = self.superview else {
            return
        }
        
        shapLayer.path = shapPath.cgPath
        shapLayer.strokeColor = borderColor.cgColor
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.lineWidth = borderWidth
        maskLayer.path = maskPath.cgPath
    }
    
    fileprivate func commonInit() {
        shapLayer.mask = maskLayer
        self.layer.addSublayer(shapLayer)
    }
    
    private let shapLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    
    private var shapPath : UIBezierPath {
        return UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius)
    }
    
    private var maskPath : UIBezierPath {
        let frame = self.bounds
        
        let clipPath = UIBezierPath()
        let clipCenter = CGPoint(x: frame.midX, y: frame.midY)
        let clipRadius = frame.width
        clipPath.move(to: clipCenter)
        clipPath.addLine(to: clipCenter.applying(CGAffineTransform(translationX: 0, y: -clipRadius)))
        
        let angle = CGFloat.pi / 180
        clipPath.addArc(withCenter: clipCenter, radius: clipRadius, startAngle: -90*angle, endAngle: (360*progress-90)*angle, clockwise: true)
        clipPath.close()
        
        return clipPath.reversing()
    }
}

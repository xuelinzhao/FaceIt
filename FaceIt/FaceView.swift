//
//  FaceView.swift
//  FaceIt
//
//  Created by Xuelin Zhao on 2017/8/5.
//  Copyright © 2017年 zhaoxuelin. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    //This variables could be changed at the inspector
    @IBInspectable
    var scale : CGFloat = 0.9 {didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var lineWidth : CGFloat = 5 {didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var color : UIColor = UIColor.blue{didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var eyesOpen : Bool = false{didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var mouthCurvature : Double = 0.5{didSet{setNeedsDisplay()}}
    
    //Change the scale of the face in the Model
    func changeScale(byReactiongTo pinchRecongizer: UIPinchGestureRecognizer){
        switch  pinchRecongizer.state {
        case .changed,.ended:
            scale *= pinchRecongizer.scale
            pinchRecongizer.scale = 1
        default:
            break
        }
    }
    
    //Private Implementation
    private struct Ratios {
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }
    
    //Set the center of skull
    private var skullCenter : CGPoint{
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    //Set the radius of skull
    private var skullRadius : CGFloat{
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    
    //Path for Skull
    private func pathForSkull() -> UIBezierPath{
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        path.lineWidth = lineWidth
        return path
    }
    
    //Enum of Eyes
    private enum Eye{
        case left
        case right
    }
    
    //Path for Eye
    private func pathForEye(_ eye : Eye) -> UIBezierPath{
        //Find the center of the Eyes
        func centerOfEye(_ eye : Eye) -> CGPoint {
            //Locate the eyeCenter to the skullCenter first
            var eyeCenter = skullCenter
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            eyeCenter.y -= eyeOffset
            //Locate the center of the eye in x axis
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        let eyeCenter = centerOfEye(eye)
        
        let path : UIBezierPath
        if eyesOpen{
            path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        }else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    //Path for Mouth
    private func pathForMouth() -> UIBezierPath{
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffest = skullRadius / Ratios.skullRadiusToMouthOffset
        
        let mouthRect = CGRect(
            x: skullCenter.x - mouthWidth / 2,
            y: skullCenter.y + mouthOffest,
            width: mouthWidth,
            height: mouthHeight
        )
        
        let smileOffset = mouthHeight * CGFloat(max(-1,min(mouthCurvature,1)))
        
        //Set the srart end control1 control2
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileOffset)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: end.y + smileOffset)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    //Draw
    override func draw(_ rect: CGRect) {
        color.set()
        pathForSkull().stroke()
        pathForEye(.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
    
}

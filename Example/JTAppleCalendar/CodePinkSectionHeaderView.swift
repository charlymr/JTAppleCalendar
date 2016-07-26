//
//  CodePinkSectionHeaderView.swift
//  JTAppleCalendar
//
//  Created by Jeron Thomas on 2016-07-15.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import JTAppleCalendar

class CodePinkSectionHeaderView: JTAppleHeaderView {
    
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0);
        let r1 = CGRect(x: 0 , y: 0, width: 25, height: 25);         // Size
        context.addRect(r1);
        context.fillPath();
        
        context.setStrokeColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0);
        context.addEllipse(inRect: CGRect(x: 0 , y: 0, width: 25, height: 25));
        context.strokePath();
     }
    
   

}

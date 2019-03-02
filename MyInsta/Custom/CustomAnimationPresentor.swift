//
//  CustomAnimationPresentor.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        // toView is CameraController:
        guard let toView = transitionContext.view(forKey: .to) else {
            LogUtils.LogDebug(type: .error, message: "toView is nil")
            return
        }
        containerView.addSubview(toView)
        transitionContext.completeTransition(true)
        
        
        
    }
    
    
    
    
}

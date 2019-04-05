//
//  CustomTransitionTabBarController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/4/2.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

class CustomTransitionTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
}

extension CustomTransitionTabBarController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if let selectedViewController = selectedViewController {
            animateTransition(from: selectedViewController, to: viewController)
        }
        
        return true
    }
}

// MARK: - Private
extension CustomTransitionTabBarController {
    func animateTransition(from oldVC: UIViewController , to newVC: UIViewController){
        guard let oldIndex = viewControllers?.firstIndex(of: oldVC), let newIndex = viewControllers?.firstIndex(of: newVC), oldIndex != newIndex,let oldView = oldVC.view, let newView = newVC.view, let snapshot = oldView.snapshotView(afterScreenUpdates: false) else {
            return
        }

        if oldIndex < newIndex {
            newView.transform = .init(translationX: newView.bounds.width, y: 0)
            snapshot.frame.origin = CGPoint(x: -oldView.frame.width, y: 0)
        } else {
            newView.transform = .init(translationX: -newView.bounds.width, y: 0)
            snapshot.frame.origin = CGPoint(x: oldView.frame.width, y: 0)
        }
        
        newView.addSubview(snapshot)
        view.isUserInteractionEnabled = false
        
        if #available(iOS 10.0, *) {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                newView.transform = .identity
            }) { (_) in
                snapshot.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                newView.transform = .identity
            }) { (_) in
                snapshot.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
}

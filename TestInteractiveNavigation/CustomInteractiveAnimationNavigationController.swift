//
//  InteractiveNavigationController.swift
//  TestInteractiveNavigation
//
//  Created by Takeru Sato on 2019/08/03.
//  Copyright © 2019 son. All rights reserved.
//


import UIKit

protocol InteractiveNavigation {
    var presentAnimation: UIViewControllerAnimatedTransitioning? { get }
    var dismissAnimation: UIViewControllerAnimatedTransitioning? { get }
    func showNext()
}

enum SwipeDirection: CGFloat, CustomStringConvertible {
    case left  = -1.0
    case none  = 0.0
    case right = 1.0

    var description: String {
        switch self {
        case .left: return "Left"
        case .none: return "None"
        case .right: return "Right"
        }
    }
}

class InteractiveNavigationController: UINavigationController , UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    var interactionController: UIPercentDrivenInteractiveTransition?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        delegate = self
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(InteractiveNavigationController.handlePan(_:))))
    }


    // MARK: - Gesture Handlers
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view else { return }

        let flickThreshold: CGFloat = 700.0
        let distanceThreshold: CGFloat = 0.3

        let velocity = gesture.velocity(in: gestureView)
        let translation = gesture.translation(in: gestureView)
        let percent = abs(translation.x / gestureView.bounds.size.width);

        var swipeDirection: SwipeDirection = (velocity.x > 0) ? .right : .left

        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()

            if swipeDirection == .left {
                let currentViewController = viewControllers.last as? InteractiveNavigation
                currentViewController?.showNext()
            }

        case .changed:
            interactionController?.update(percent)

        case .cancelled:
            interactionController?.cancel()

        case .ended:
            if let interactionController = self.interactionController {
                if abs(percent) > distanceThreshold || abs(velocity.x) > flickThreshold {
                    interactionController.finish()
                } else {
                    interactionController.cancel()
                }

                self.interactionController = nil
                swipeDirection = .none
            }

        default:
            break
        }
    }

    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let _ = presenting as? InteractiveNavigation else { return nil }
        if let currentViewController = viewControllers.last as? InteractiveNavigation {
            return currentViewController.presentAnimation
        }
        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard viewControllers.count != 1 else { return nil }
        if let currentViewController = viewControllers.last as? InteractiveNavigation {
            return currentViewController.dismissAnimation
        }
        return nil
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return PushAnimatedTransitioning()
        case .pop: 
            guard let currentViewController = viewControllers.last as? InteractiveNavigation else { return nil }
            return currentViewController.dismissAnimation
        case .none: return nil
        default: return nil
        }
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

class PushAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.center.x += containerView.bounds.width
        containerView.addSubview(toViewController.view)
        UIView.animate(withDuration: duration, animations: {
            fromViewController.view.center.x -= containerView.bounds.width / 2
            toViewController.view.center.x -= containerView.bounds.width
        }) { completed in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

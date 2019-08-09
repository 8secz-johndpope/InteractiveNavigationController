//
//  ViewController.swift
//  TestInteractiveNavigation
//
//  Created by Takeru Sato on 2019/08/03.
//  Copyright © 2019 son. All rights reserved.
//

import UIKit

class ViewController: UIViewController, InteractiveNavigation {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    var presentAnimation: UIViewControllerAnimatedTransitioning? {
        return nil
    }

    var dismissAnimation: UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func showNext() {
        let viewController = NextViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}


class NextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}


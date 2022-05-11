//
//  ReaderNavigationController.swift
//  Aidoku (iOS)
//
//  Created by Skitty on 12/23/21.
//
import UIKit

public class ReaderNavigationController: UINavigationController {

    public override var childForStatusBarHidden: UIViewController? {
        topViewController
    }

    public override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}

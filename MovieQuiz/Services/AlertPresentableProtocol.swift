//
//  AlertPresentableProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 12.02.2023.
//

import UIKit

protocol AlertPresentableProtocol {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension UIViewController: AlertPresentableProtocol {
    }

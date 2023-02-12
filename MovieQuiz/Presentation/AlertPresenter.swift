//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 05.01.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    var delegate: MovieQuizViewControllerProtocol?
    
    init(delegate: MovieQuizViewControllerProtocol) {
        self.delegate = delegate
    }
    
    func showAlert(result: AlertModel) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .cancel) {_ in
            result.completion()
        }
        alert.view.accessibilityIdentifier = "idAlert"
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}


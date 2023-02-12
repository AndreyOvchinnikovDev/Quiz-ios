//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 12.02.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AlertPresentableProtocol {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}

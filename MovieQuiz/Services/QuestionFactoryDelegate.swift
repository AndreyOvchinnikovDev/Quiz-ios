//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 03.01.2023.
//

protocol QuestionFactoryDelegate : AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

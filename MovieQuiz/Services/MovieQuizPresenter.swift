//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 11.02.2023.
//
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 2
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    weak var viewController: MovieQuizViewController?
    
    var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestionIndex : Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
        
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
//        showLoadingIndicator()
            if self.isLastQuestion() {
            statisticService = StatisticServiceImplementation()
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            
            let result = AlertModel(
                title: "Этот раунд окончен!",
                message:"""
                 Ваш результат: \(correctAnswers)/\(self.questionsAmount)
            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
             Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(self.questionsAmount) (\(statisticService?.bestGame.date ?? "Ошибка"))
              Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
           """,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            )
                viewController?.alertPresenter?.showAlert(result: result)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
          
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
}

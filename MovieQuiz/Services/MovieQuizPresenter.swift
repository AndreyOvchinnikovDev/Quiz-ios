//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 11.02.2023.
//
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    var alertPresenter: AlertPresenterProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var viewController: MovieQuizViewControllerProtocol?
    private var statisticService: StatisticService?
    private var currentQuestionIndex : Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        alertPresenter = AlertPresenter(delegate: viewController)
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: String) {
        let message = error
        viewController?.showNetworkError(message: message)
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
    // MARK: - public methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
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
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func showNextQuestionOrResults() {
            if self.isLastQuestion() {
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
                    self.restartGame()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            )
                alertPresenter?.showAlert(result: result)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
          if isCorrectAnswer {
              correctAnswers += 1
          }
      }
    
        // MARK: - private methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
}


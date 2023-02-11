import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    var alertPresenter: AlertPresenterProtocol?
    private let presenter = MovieQuizPresenter()
    
    private var correctAnswers: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
        activityIndicator.hidesWhenStopped = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        UIStatusBarStyle.lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        activityIndicator.stopAnimating()
        yesButton.isEnabled = true
        noButton.isEnabled = true
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: String) {
        showNetworkError(message: error)
    }
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
  
        presenter.yesButtonClicked()
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
       
        presenter.noButtonClicked()
        
    }
    
    // MARK: - Private methods
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor :
        UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.showLoadingIndicator()
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
//    private func showNextQuestionOrResults() {
//        showLoadingIndicator()
//            if presenter.isLastQuestion() {
//
//            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
//
//            let result = AlertModel(
//                title: "Этот раунд окончен!",
//                message:"""
//                 Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
//            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
//             Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(presenter.questionsAmount) (\(statisticService?.bestGame.date ?? "Ошибка"))
//              Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
//           """,
//                buttonText: "Сыграть еще раз",
//                completion: { [weak self] in
//                    guard let self = self else { return }
//                    self.presenter.resetQuestionIndex()
//                    self.correctAnswers = 0
//                    self.questionFactory?.requestNextQuestion()
//                }
//            )
//            alertPresenter?.showAlert(result: result)
//        } else {
//            presenter.switchToNextQuestion()
//            questionFactory?.requestNextQuestion()
//
//        }
//    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.switchToNextQuestion()
            self.correctAnswers = 0
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.showAlert(result: model)
    }
}


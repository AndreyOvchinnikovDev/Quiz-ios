//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 02.01.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private lazy var unusedQuestion = movies
    private var moviesError: String = ""
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.moviesError = mostPopularMovies.errorMessage
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error.localizedDescription)
                }
            }
        }
    }

    func requestNextQuestion() {
        if movies.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didFailToLoadData(with: self.moviesError)
            }
        }
        if unusedQuestion.isEmpty {
            unusedQuestion = movies
        }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.unusedQuestion.count).randomElement() ?? 0
            
            guard let movie = self.unusedQuestion[safe: index] else { return }
            self.unusedQuestion.remove(at: index)
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: "Failed to load image")
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomRating = Array(8...9).randomElement()
            let randomOperator = ["больше", "меньше"].randomElement()
            let text = "Рейтинг этого фильма \(randomOperator ?? "больше") чем \(randomRating ?? 0)?"
            
            let correctAnswer = randomOperator == "больше" ? rating  > Float(randomRating ?? 0) :
                                                             rating  < Float(randomRating ?? 0)
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
}


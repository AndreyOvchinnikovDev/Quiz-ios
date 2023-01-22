//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 11.01.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get set }
}

final class StatisticServiceImplementation: StatisticService {
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private let userDefaults = UserDefaults.standard
    
    // MARK: - лучший результат
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date().dateTimeString)
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // MARK: - количество сыгранных раундов
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // MARK: - соотношение всех ответов
    var totalAccuracy: Double {
        (correct / total) * 100
    }
    
    // MARK: - количество правильных ответов
    var correct: Double {
        get {
            userDefaults.double(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    // MARK: - количество всех вопросов
    var total: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    // MARK: - метод сохранения рекорда(если он лучше), и сохранение(добавление) вопросов и правильных ответов
    func store(correct count: Int, total amount: Int) {
        let gameRecordModel = GameRecord(correct: count, total: amount, date: Date().dateTimeString)
        
        if gameRecordModel > bestGame {
            bestGame = gameRecordModel
        }
        
        if gamesCount == 0 {
            correct = Double(count)
            total = Double(amount)
        } else {
            correct += Double(count)
            total += Double(amount)
        }
        
        gamesCount += 1
    }
}

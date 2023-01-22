//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Andrey Ovchinnikov on 11.01.2023.
//

import Foundation

struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: String
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
}

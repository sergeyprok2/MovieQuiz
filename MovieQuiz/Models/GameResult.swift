//
//  GameResult.swift
//  MovieQuiz
//
//

import Foundation

struct GameResult {
    ///    количество правильных ответов
    let correct: Int
    ///    количество вопросов квиза
    let total: Int
    ///    дата завершения раунда
    let date: Date

    /// метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

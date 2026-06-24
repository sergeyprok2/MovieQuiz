//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//

import Foundation

protocol StatisticServiceProtocol {
//    счётчик сыгранных игр
    var gamesCount: Int { get }
//    Лучшая игра
    var bestGame: GameResult { get }
//    Средняя точность ответов — это процент правильных ответов от общего числа вопросов
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

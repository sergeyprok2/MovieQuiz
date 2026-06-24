//
//  StatisticService.swift
//  MovieQuiz
//
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
//    Убираем дублирование в коде: обращения к UserDefaults
    private let storage: UserDefaults = .standard
    
//    общее количество правильных ответов за все игры
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
//    общее количество вопросов, заданных за все игры
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    
    private enum Keys: String {
        case gamesCount          // Для счётчика сыгранных игр
        case bestGameCorrect     // Для количества правильных ответов в лучшей игре
        case bestGameTotal       // Для общего количества вопросов в лучшей игре
        case bestGameDate        // Для даты лучшей игры
        case totalCorrectAnswers // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
    }
    
//    счётчик сыгранных игр
    var gamesCount: Int {
        get {
                // чтение значения из UserDefaults
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            // запись значения newValue в UserDefaults
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
//    Лучшая игра
    var bestGame: GameResult {
        get {
            // Добавьте чтение значений полей GameResult(correct, total и date) из UserDefaults,
            // затем создайте GameResult от полученных значений
            // Читаем значения из UserDefaults
            
//            количество правильных ответов в лучшей игре
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            
//            общее количество вопросов в лучшей игре
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)

            // Читаем дату: если не сохранена, используем текущую
            if let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                return GameResult(correct: correct, total: total, date: date)
            } else {
                return GameResult(correct: correct, total: total, date: Date())
            }
        }
        set {
            // Добавьте запись значений каждого поля из newValue в UserDefaults
            UserDefaults.standard.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            UserDefaults.standard.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            UserDefaults.standard.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

//    Средняя точность ответов — это процент правильных ответов от общего числа вопросов
    var totalAccuracy: Double {
        get {
            // Добавьте чтение значения из UserDefaults
//            let totalQuestions = gamesCount * 10
            guard totalQuestionsAsked > 0 else { return 0 }
            return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // 1. Обновляем количество сыгранных игр
        gamesCount += 1
        
        // 2. Обновляем общее количество правильных ответов и заданных вопросов
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        
        // 3. Создаём объект текущей игры для сравнения с рекордом
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        
        // 3. Получаем текущий сохраненный рекорд
        let existingBest = bestGame
            
        if currentGame.isBetterThan(existingBest) {
            bestGame = currentGame  // Сохраняем новый рекорд
        }
    }
    
    
}

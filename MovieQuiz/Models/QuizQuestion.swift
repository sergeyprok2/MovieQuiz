//
//  QuizQuestion.swift
//  MovieQuiz
//
//

import Foundation

struct QuizQuestion {
    
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let imageName: Data
    // строка с вопросом о рейтинге фильма
    let text: String
    
    let correctAnswer: Bool
    
    // булевое значение (true, false), правильный ответ на вопрос
//    let correctAnswer: Bool
}

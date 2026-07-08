//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showQuizResults(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func resetUI()
}

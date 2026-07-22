//
//  MovieQuizPrezenterTests.swift
//  MovieQuizPrezenterTests
//
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var lastStepModel: QuizStepViewModel?
    func show(quiz step: QuizStepViewModel) {
        lastStepModel = step
    }
    
    func showQuizResults(quiz result: QuizResultsViewModel) {
    
    }
    
    func highlightImageBorder(isCorrect: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    
    func showNetworkError(message: String) {
    
    }
    
    func resetUI() {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(imageName: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        // Вместо проверки viewControllerMock проверяем саму viewModel, которую только что получили
        XCTAssertEqual(viewModel.image, emptyData)
//        XCTAssertEqual(viewControllerMock.lastStepModel?.image, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

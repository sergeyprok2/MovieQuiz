//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//

import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticServiceProtocol!
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    var correctAnswers: Int = 0
    
    //    общее количество вопросов для квиза. Пусть оно будет равно десяти
    let questionsAmount: Int = 10
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        // Вот здесь просим Вью Контроллер сбросить UI на экране:
        viewController?.resetUI()
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //    вопрос, который видит пользователь.
    var currentQuestion: QuizQuestion?
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.imageName,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func showNextQuestionOrResults() {
        
//        imageView.layer.borderWidth = 0
        
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            
            // идём в состояние "Результат квиза"
            let text =
                """
                Ваш результат: \(correctAnswers) из \(self.questionsAmount)
                Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0.0))%
                """
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.showQuizResults(quiz: viewModel)
            
            

        } else {

//            imageView.layer.borderWidth = 0
            
            self.switchToNextQuestion()
            

            questionFactory?.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        // увеличиваем счетчик, если ответ верный
        if isCorrect {
            correctAnswers += 1
        }
        
        // 2. Говорим контроллеру покрасить рамку
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        // 3. Запускаем таймер на следующий вопрос
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
}

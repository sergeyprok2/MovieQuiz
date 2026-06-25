import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    //    общее количество вопросов для квиза. Пусть оно будет равно десяти
    private let questionsAmount: Int = 10
    //    фабрика вопросов. Контроллер будет обращаться за вопросами к ней.
    private var questionFactory: QuestionFactoryProtocol?
    //    вопрос, который видит пользователь.
    private var currentQuestion: QuizQuestion?
    
    
    private var alertPresenter = AlertPresenter()
    
    var statisticService: StatisticServiceProtocol?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Bundle.main.bundlePath)
//        print(NSHomeDirectory())
        UserDefaults.standard.set(true, forKey: "viewDidLoad")
        
        let statisticService: StatisticServiceProtocol = StatisticService()

        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
        
    
    
    
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
//        let currentQuestion = questions[currentQuestionIndex] // 1
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // 3
        
        // Блокируем кнопку
        yesButton.isEnabled = false
        
    
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
//        let currentQuestion = questions[currentQuestionIndex] // 1
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) //
        
        // Блокируем кнопку
        noButton.isEnabled = false
    }
    
    

    
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.imageName) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // 4
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        // попробуйте написать код показа на экран самостоятельно
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // 3
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        
            
        }
        
    }
    
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
//        guard let service = statisticService else { return }
        
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
//            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)" // 1
            let text = 
                """
                Ваш результат: \(correctAnswers) из 10
                Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
                """
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            
            // Разблокируем кнопки
            yesButton.isEnabled = true
            noButton.isEnabled = true
        } else {
            yesButton.isEnabled = true
            noButton.isEnabled = true
            imageView.layer.borderWidth = 0
            
            currentQuestionIndex += 1
            
//            let nextQuestion = questions[currentQuestionIndex]
//            let viewModel = convert(model: nextQuestion)
//            
//            show(quiz: viewModel)
            questionFactory = QuestionFactory(delegate: self)
            questionFactory?.requestNextQuestion()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
        
    }
    
    
    private func restartGame() {
        // Сбрасываем индекс текущего вопроса на первый (0)
        currentQuestionIndex = 0
        
        // Обнуляем счётчик правильных ответов
        correctAnswers = 0
        
        // Убираем рамку с изображения, если она осталась от предыдущего раунда
        imageView.layer.borderWidth = 0
        
        // Разблокируем кнопки ответов на случай, если они были заблокированы
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        // Запрашиваем первый вопрос через существующую фабрику
        // (не создаём новую — используем уже инициализированную в viewDidLoad)
        questionFactory?.requestNextQuestion()
    }

    
    
}








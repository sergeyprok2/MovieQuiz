import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Bundle.main.bundlePath)
//        print(NSHomeDirectory())
//         РАСКОММЕНТИРУЙ СТРОЧКУ НИЖЕ, ЕСЛИ НАДО СБРОСИТЬ ВСЮ СТАТИСТИКУ:
//        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)

        showLoadingIndicator()
    }
        
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
        // Блокируем кнопки
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        
        // Блокируем кнопки
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private functions
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            
            self.presenter.restartGame()
           
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        //  Разблокируем кнопки
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    func highlightImageBorder(isCorrect: Bool) {
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // 3
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
    }
    
    func showQuizResults(quiz result: QuizResultsViewModel) {
//        print("���G: statisticService is \(statisticService != nil ? "PRESENT" : "NIL")")
        
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
        
    }
    
    func resetUI() {
        imageView.layer.borderWidth = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
     
}










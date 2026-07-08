//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testScreenCast() throws { }
    
    func testYesButton() {
        sleep(20)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        // Превращаем байты обратно в UIImage для отладки
        if let debugImage = UIImage(data: firstPosterData) {
            print("--- DEBUG IMAGE CREATED ---") // Ставим брейкпоинт сюда или смотрим через Variable View
        }
        
        app.buttons["Yes"].tap()
        sleep(10)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        // Превращаем байты обратно в UIImage для отладки
        if let debugImage1 = UIImage(data: secondPosterData) {
            print("--- DEBUG IMAGE CREATED ---") // Ставим брейкпоинт сюда или смотрим через Variable View
        }

        let indexLabel = app.staticTexts["Index"]
        // 1. Добавляем принт текущего текста лейбла в консоль
        print("--- DEBUG: Текущий текст indexLabel перед ассертом: '\(indexLabel.label)' ---")
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(15)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(10)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(10)
        for i in 1...10 {
            print("вопрос \(i) загрузился")
            app.buttons["No"].tap()
            sleep(5)
            if i == 10 {
                break
            }
            var t = 0
            for _ in 1...100000 {
                let indexLabel = app.staticTexts["Index"]
                let expectedText = "\(i + 1)/10"
                if indexLabel.label == expectedText {
                    break
                } else if t == 10 {
                    app.buttons["No"].tap()
                    t = 0
                } else {
                    t += 1
                    print("картинка \(i + 1) еще грузится")
                    sleep(2)
                    continue
                }
            }
        }
        
        // Делаем скриншот ТОГО, что сейчас на экране вместо алерта
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "What_Is_On_Screen_Instead_Of_Alert"
        attachment.lifetime = .keepAlways
        add(attachment)

        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
//        sleep(10)
//        for _ in 1...10 {
//            app.buttons["No"].tap()
//            sleep(5)
//        }
        sleep(10)
        for i in 1...10 {
            print("вопрос \(i) загрузился")
            app.buttons["No"].tap()
            sleep(5)
            if i == 10 {
                break
            }
            var t = 0
            for _ in 1...100000 {
                let indexLabel = app.staticTexts["Index"]
                let expectedText = "\(i + 1)/10"
                if indexLabel.label == expectedText {
                    break
                } else if t == 10 {
                    app.buttons["No"].tap()
                    t = 0
                } else {
                    t += 1
                    print("картинка \(i + 1) еще грузится")
                    sleep(2)
                    continue
                }
            }
        }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}

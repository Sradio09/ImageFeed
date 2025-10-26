import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    func testAuth() throws {
        // MARK: - 1. Нажать кнопку авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5),
                      "Кнопка 'Authenticate' не найдена на стартовом экране")
        authButton.tap()
        
        // MARK: - 2. Подождать появления WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10),
                      "WebView с авторизацией не появился на экране")
        
        // MARK: - 3. Вводим логин
        let loginTextField = webView.textFields.element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5),
                      "Поле логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        
        if app.keyboards.count > 0 {
            webView.swipeUp()
        }
        
        // MARK: - 4. Вводим пароль
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5),
                      "Поле пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText("<Ваш пароль>")
        
        if app.keyboards.count > 0 {
            webView.swipeUp()
        }
        
        // MARK: - 5. Нажать кнопку входа
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5),
                      "Кнопка 'Login' не найдена")
        loginButton.tap()
        
        // MARK: - 6. Проверить, что открылась лента (ImagesList)
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15),
                      "Не удалось загрузить экран ленты (ImagesList)")
    }
    
    
    func testFeed() throws {
        // MARK: - 1. Ждём загрузки первой ячейки ленты
        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10),
                      "Первая ячейка ленты не загрузилась")
        
        // MARK: - 2. Скроллим ленту вверх
        firstCell.swipeUp()
        sleep(1)
        
        // MARK: - 3. Ставим лайк на второй ячейке
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5),
                      "Вторая ячейка ленты не найдена")
        
        let likeOffButton = cellToLike.buttons["likeButtonOff"]
        XCTAssertTrue(likeOffButton.exists, "Кнопка 'likeButtonOfff' не найдена")
        likeOffButton.tap()
        
        // MARK: - 4. Убираем лайк
        let likeOnButton = cellToLike.buttons["likeButtonOn"]
        XCTAssertTrue(likeOnButton.waitForExistence(timeout: 3),
                      "Кнопка 'likeButtonOn' не найдена после нажатия")
        likeOnButton.tap()
        
        sleep(1)
        
        // MARK: - 5. Открываем картинку
        cellToLike.tap()
        sleep(2)
        
        // MARK: - 6. Проверяем, что картинка открылась
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10),
                      "Полноэкранное изображение не появилось")
        
        // MARK: - 7. Увеличиваем изображение
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        
        // MARK: - 8. Уменьшаем изображение
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        // MARK: - 9. Возвращаемся на экран ленты
        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5),
                      "Кнопка 'Назад' (nav back button white) не найдена")
        backButton.tap()
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5),
                      "После возврата экран ленты не отобразился")
    }
    
    func testProfile() throws {
        // MARK: - 1. Подождать загрузку ленты
        sleep(3)
        
        // MARK: - 2. Перейти на экран профиля
        let profileTabButton = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTabButton.waitForExistence(timeout: 5),
                      "Кнопка вкладки профиля не найдена")
        profileTabButton.tap()
        sleep(2)
        
        // MARK: - 3. Проверить, что отображаются персональные данные
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists,
                      "Имя пользователя не отображается")
        XCTAssertTrue(app.staticTexts["@username"].exists,
                      "Логин пользователя не отображается")
        
        // MARK: - 4. Нажать кнопку выхода
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5),
                      "Кнопка выхода не найдена")
        logoutButton.tap()
        sleep(1)
        
        // MARK: - 5. Подтвердить выход
        let alert = app.alerts["Выход из аккаунта"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5),
                      "Алерт подтверждения выхода не появился")
        
        alert.buttons["Выйти"].tap()
        sleep(2)
        
        // MARK: - 6. Проверить, что открылся экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10),
                      "Экран авторизации не открылся после выхода из профиля")
    }
}

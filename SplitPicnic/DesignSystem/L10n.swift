import Foundation

struct L10n: Equatable, Sendable {
    var language: AppLanguage

    subscript(_ key: String) -> String {
        Self.table[key]?[language] ?? Self.table[key]?[.english] ?? key
    }

    private static let table: [String: [AppLanguage: String]] = [
        "tagline": [
            .english: "One slice. Two happy guests.",
            .russian: "Один разрез. Два довольных гостя.",
            .ukrainian: "Один розріз. Два щасливі гості.",
        ],
        "play": [.english: "Play", .russian: "Играть", .ukrainian: "Грати"],
        "worlds": [.english: "Worlds", .russian: "Миры", .ukrainian: "Світи"],
        "daily": [.english: "Daily Puzzle", .russian: "Загадка дня", .ukrainian: "Загадка дня"],
        "collection": [.english: "Collection", .russian: "Коллекция", .ukrainian: "Колекція"],
        "settings": [.english: "Settings", .russian: "Настройки", .ukrainian: "Налаштування"],
        "slice": [.english: "Slice!", .russian: "Резать!", .ukrainian: "Різати!"],
        "tryAgain": [.english: "Try Again", .russian: "Ещё раз", .ukrainian: "Ще раз"],
        "showHint": [.english: "Show a Hint", .russian: "Подсказка", .ukrainian: "Підказка"],
        "nextLevel": [.english: "Next Level", .russian: "Дальше", .ukrainian: "Далі"],
        "replay": [.english: "Replay", .russian: "Повтор", .ukrainian: "Повтор"],
        "perfect": [.english: "Perfect Slice!", .russian: "Идеальный кусок!", .ukrainian: "Ідеальний шматок!"],
        "bothHappy": [
            .english: "Both guests are happy!",
            .russian: "Оба гостя довольны!",
            .ukrainian: "Обидва гості щасливі!",
        ],
        "notQuite": [.english: "Not Quite!", .russian: "Почти!", .ukrainian: "Майже!"],
        "checkRequests": [
            .english: "Check each guest’s request and give them a better slice!",
            .russian: "Проверь заказ каждого гостя и дай лучший кусок!",
            .ukrainian: "Перевір замовлення кожного гостя і дай кращий шматок!",
        ],
        "sound": [.english: "Sound", .russian: "Звук", .ukrainian: "Звук"],
        "soundSub": [
            .english: "Play game sound effects",
            .russian: "Звуки игры",
            .ukrainian: "Звуки гри",
        ],
        "music": [.english: "Music", .russian: "Музыка", .ukrainian: "Музика"],
        "musicSub": [
            .english: "Play background music",
            .russian: "Фоновая музыка",
            .ukrainian: "Фонова музика",
        ],
        "haptics": [.english: "Haptic Feedback", .russian: "Вибрация", .ukrainian: "Вібрація"],
        "hapticsSub": [
            .english: "Feel the game come alive",
            .russian: "Ощущать разрезы",
            .ukrainian: "Відчувати розрізи",
        ],
        "language": [.english: "Language", .russian: "Язык", .ukrainian: "Мова"],
        "languageSub": [
            .english: "Choose your language",
            .russian: "Выбери язык",
            .ukrainian: "Обери мову",
        ],
        "reduceMotion": [.english: "Reduce Motion", .russian: "Меньше движения", .ukrainian: "Менше руху"],
        "reduceMotionSub": [
            .english: "Simplify animations",
            .russian: "Упростить анимации",
            .ukrainian: "Спростити анімації",
        ],
        "howToPlay": [.english: "How to Play", .russian: "Как играть", .ukrainian: "Як грати"],
        "drawLine": [
            .english: "Draw one straight line to split the food.",
            .russian: "Проведи одну прямую линию, чтобы разделить угощение.",
            .ukrainian: "Проведи одну пряму лінію, щоб розділити частування.",
        ],
        "next": [.english: "Next", .russian: "Дальше", .ukrainian: "Далі"],
        "theRest": [.english: "You get the rest!", .russian: "Тебе остальное!", .ukrainian: "Тобі решта!"],
        "justPepperoni": [.english: "Just pepperoni!", .russian: "Только пепперони!", .ukrainian: "Лише пепероні!"],
        "motto": [
            .english: "Good slices lead to brighter days",
            .russian: "Хорошие куски — к светлым дням",
            .ukrainian: "Гарні шматки ведуть до світлих днів",
        ],
        "themes": [.english: "Themes", .russian: "Темы", .ukrainian: "Теми"],
        "food": [.english: "Food", .russian: "Еда", .ukrainian: "Їжа"],
        "guests": [.english: "Guests", .russian: "Гости", .ukrainian: "Гості"],
        "owned": [.english: "Owned", .russian: "Есть", .ukrainian: "Є"],
        "equipped": [.english: "Equipped", .russian: "Надето", .ukrainian: "Надіто"],
        "unlock": [.english: "Unlock", .russian: "Открыть", .ukrainian: "Відкрити"],
        "dailyTitle": [.english: "Daily Puzzle", .russian: "Загадка дня", .ukrainian: "Загадка дня"],
        "dailyBlurb": [
            .english: "A fresh slice of happiness every day!",
            .russian: "Свежий кусок счастья каждый день!",
            .ukrainian: "Свіжий шматок щастя щодня!",
        ],
        "streak": [.english: "Day Streak!", .russian: "дней подряд!", .ukrainian: "днів поспіль!"],
        "resets": [.english: "Resets in", .russian: "Сброс через", .ukrainian: "Скидання через"],
        "pause": [.english: "Pause", .russian: "Пауза", .ukrainian: "Пауза"],
        "resume": [.english: "Resume", .russian: "Продолжить", .ukrainian: "Продовжити"],
        "home": [.english: "Home", .russian: "Домой", .ukrainian: "Додому"],
        "locked": [.english: "Locked", .russian: "Закрыто", .ukrainian: "Закрито"],
        "reset": [.english: "Reset progress", .russian: "Сбросить прогресс", .ukrainian: "Скинути прогрес"],
        "want": [.english: "I want", .russian: "Хочу", .ukrainian: "Хочу"],
        "no": [.english: "No", .russian: "Без", .ukrainian: "Без"],
        "only": [.english: "only", .russian: "только", .ukrainian: "лише"],
        "and": [.english: "and", .russian: "и", .ukrainian: "і"],
        "fair": [
            .english: "Keep the slices close in size.",
            .russian: "Куски должны быть почти равными.",
            .ukrainian: "Шматки мають бути майже рівними.",
        ],
        "adjust": [
            .english: "Drag the handles. Slice when it looks right.",
            .russian: "Подвинь ручки. Режь, когда линия на месте.",
            .ukrainian: "Посунь ручки. Ріж, коли лінія на місці.",
        ],
        "tutorial2": [
            .english: "Each guest has a request. One cut has to make both of them happy.",
            .russian: "У каждого гостя свой заказ. Один разрез должен порадовать обоих.",
            .ukrainian: "У кожного гостя своє замовлення. Один розріз має порадувати обох.",
        ],
        "tutorial3": [
            .english: "You can nudge the line before you confirm. This is a puzzle, not a test of your fingertip.",
            .russian: "Линию можно поправить до подтверждения. Это головоломка, а не экзамен на точность пальца.",
            .ukrainian: "Лінію можна поправити до підтвердження. Це головоломка, а не іспит на точність пальця.",
        ],
        "startPicnic": [
            .english: "Start the picnic",
            .russian: "Начать пикник",
            .ukrainian: "Почати пікнік",
        ],
        "version": [.english: "Version", .russian: "Версия", .ukrainian: "Версія"],
        "about": [
            .english: "Split Picnic is a short slicing puzzle. Draw one straight line. Feed two guests. No account, no ads, no tracking.",
            .russian: "Split Picnic — короткая головоломка на один разрез. Накорми двух гостей. Без аккаунта, рекламы и слежки.",
            .ukrainian: "Split Picnic — коротка головоломка на один розріз. Нагодуй двох гостей. Без акаунта, реклами і стеження.",
        ],
    ]
}

enum ToppingCopy {
    static func name(_ kind: ToppingKind, language: AppLanguage) -> String {
        switch (kind, language) {
        case (.pepperoni, .english): "pepperoni"
        case (.pepperoni, .russian): "пепперони"
        case (.pepperoni, .ukrainian): "пепероні"
        case (.mushroom, .english): "mushrooms"
        case (.mushroom, .russian): "грибы"
        case (.mushroom, .ukrainian): "гриби"
        case (.olive, .english): "olives"
        case (.olive, .russian): "оливки"
        case (.olive, .ukrainian): "оливки"
        case (.pepper, .english): "peppers"
        case (.pepper, .russian): "перцы"
        case (.pepper, .ukrainian): "перці"
        case (.basil, .english): "basil"
        case (.basil, .russian): "базилик"
        case (.basil, .ukrainian): "базилік"
        case (.strawberry, .english): "strawberries"
        case (.strawberry, .russian): "клубника"
        case (.strawberry, .ukrainian): "полуниця"
        case (.blueberry, .english): "blueberries"
        case (.blueberry, .russian): "черника"
        case (.blueberry, .ukrainian): "чорниця"
        case (.cherry, .english): "cherries"
        case (.cherry, .russian): "вишня"
        case (.cherry, .ukrainian): "вишня"
        }
    }

    static func phrase(_ order: GuestOrder, language: AppLanguage) -> String {
        let loc = L10n(language: language)
        if order.isRemainder { return loc["theRest"] }
        if !order.allowOthers, order.required.count == 1, order.required[0].min <= 1 {
            return "\(loc["want"]) \(ToppingCopy.name(order.required[0].kind, language: language))!"
        }
        var parts: [String] = []
        for rule in order.required {
            let n = name(rule.kind, language: language)
            if rule.min == rule.max {
                parts.append("\(rule.min) \(n)")
            } else {
                parts.append(n)
            }
        }
        var text = loc["want"] + " " + parts.joined(separator: " \(loc["and"]) ")
        if !order.forbidden.isEmpty {
            let forb = order.forbidden.map { name($0, language: language) }.joined(separator: ", ")
            text += ". \(loc["no"]) \(forb)!"
        } else if !order.allowOthers {
            text += " \(loc["only"])!"
        } else {
            text += "!"
        }
        return text
    }
}

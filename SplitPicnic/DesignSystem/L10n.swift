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
        "picnic": [.english: "Picnic", .russian: "Пикник", .ukrainian: "Пікнік"],
        "picnicPreparing": [
            .english: "Preparing the picnic",
            .russian: "Готовим пикник",
            .ukrainian: "Готуємо пікнік",
        ],
        "picnicTableSet": [
            .english: "The table is being set",
            .russian: "Накрываем на стол",
            .ukrainian: "Накриваємо на стіл",
        ],
        "picnicFriendsArriving": [
            .english: "Friends are arriving",
            .russian: "Собираются друзья",
            .ukrainian: "Збираються друзі",
        ],
        "picnicInFullSwing": [
            .english: "Picnic in full swing",
            .russian: "Пикник в самом разгаре",
            .ukrainian: "Пікнік у самому розпалі",
        ],
        "picnicComplete": [
            .english: "Picnic complete!",
            .russian: "Пикник удался!",
            .ukrainian: "Пікнік вдався!",
        ],
        "daily": [.english: "Daily Puzzle", .russian: "Загадка дня", .ukrainian: "Загадка дня"],
        "collection": [.english: "Collection", .russian: "Коллекция", .ukrainian: "Колекція"],
        "settings": [.english: "Settings", .russian: "Настройки", .ukrainian: "Налаштування"],
        "level": [.english: "Level", .russian: "Уровень", .ukrainian: "Рівень"],
        "difficulty": [.english: "Difficulty", .russian: "Сложность", .ukrainian: "Складність"],
        "slice": [.english: "Slice!", .russian: "Резать!", .ukrainian: "Різати!"],
        "tryAgain": [.english: "Try Again", .russian: "Ещё раз", .ukrainian: "Ще раз"],
        "showHint": [.english: "Show a Hint", .russian: "Подсказка", .ukrainian: "Підказка"],
        "replayHint": [.english: "Replay hint", .russian: "Повторить подсказку", .ukrainian: "Повторити підказку"],
        "hintGuide": [
            .english: "Swipe along the glowing path.",
            .russian: "Проведи пальцем по светящейся дорожке.",
            .ukrainian: "Проведи пальцем по сяйливій доріжці.",
        ],
        "watchTutorial": [.english: "Watch demo", .russian: "Показать пример", .ukrainian: "Показати приклад"],
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
        "replayTutorialClip": [.english: "Replay animation", .russian: "Повторить анимацию", .ukrainian: "Повторити анімацію"],
        "done": [.english: "Done", .russian: "Готово", .ukrainian: "Готово"],
        "cutTutorialClip": [
            .english: "A curved finger swipe cuts and separates the pizza",
            .russian: "Кривой жест пальцем разрезает пиццу на две части",
            .ukrainian: "Кривий рух пальцем розрізає піцу на дві частини",
        ],
        "servingTutorialClip": [
            .english: "Each sliced half goes to its matching guest",
            .russian: "Каждая половинка отправляется своему гостю",
            .ukrainian: "Кожна половинка дістається своєму гостю",
        ],
        "drawLine": [
            .english: "Slash freely through the food — straight or curved. It follows your finger and slices when you let go.",
            .russian: "Режь свободным движением — прямо или по кривой. Разрез повторит путь пальца.",
            .ukrainian: "Ріж вільним рухом — прямо або по кривій. Розріз повторить шлях пальця.",
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
        "themeRotationHint": [
            .english: "The tablecloth changes as you play. Choose where the cycle begins.",
            .russian: "Скатерть меняется по мере игры. Выбери, с какой начать.",
            .ukrainian: "Скатертина змінюється під час гри. Обери, з якої почати.",
        ],
        "rotationStart": [
            .english: "Cycle starts here",
            .russian: "Начало смены",
            .ukrainian: "Початок зміни",
        ],
        "useAsStart": [
            .english: "Start with this",
            .russian: "Начать с этой",
            .ukrainian: "Почати з цієї",
        ],
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
        "fairChallenge": [
            .english: "Fair pieces",
            .russian: "Равные куски",
            .ukrainian: "Рівні шматки",
        ],
        "cleanChallenge": [
            .english: "Don't touch toppings",
            .russian: "Не задень начинку",
            .ukrainian: "Не зачепи начинку",
        ],
        "fairMiss": [
            .english: "The pieces were too different in size.",
            .russian: "Куски получились слишком разными.",
            .ukrainian: "Шматки вийшли надто різними.",
        ],
        "cleanMiss": [
            .english: "The swipe touched a topping.",
            .russian: "Разрез задел начинку.",
            .ukrainian: "Розріз зачепив начинку.",
        ],
        "swipeToSlice": [
            .english: "Slash freely — straight or curved",
            .russian: "Режь свободно — прямо или по кривой",
            .ukrainian: "Ріж вільно — прямо або по кривій",
        ],
        "tutorial2": [
            .english: "Each guest has a request. One cut has to make both of them happy.",
            .russian: "У каждого гостя свой заказ. Один разрез должен порадовать обоих.",
            .ukrainian: "У кожного гостя своє замовлення. Один розріз має порадувати обох.",
        ],
        "tutorial3": [
            .english: "Later picnics mix exact counts, forbidden toppings, fair portions, and clean swipes that touch no food. A hint shows the best path.",
            .russian: "Дальше будут точные количества, запретные начинки, равные куски и чистые разрезы между начинками. Подсказка покажет лучший путь.",
            .ukrainian: "Далі будуть точні кількості, заборонені начинки, рівні шматки й чисті розрізи між начинками. Підказка покаже найкращий шлях.",
        ],
        "startPicnic": [
            .english: "Start the picnic",
            .russian: "Начать пикник",
            .ukrainian: "Почати пікнік",
        ],
        "version": [.english: "Version", .russian: "Версия", .ukrainian: "Версія"],
        "about": [
            .english: "Split Picnic is a short slicing puzzle. Swipe once. Feed two guests. No account, no ads, no tracking.",
            .russian: "Split Picnic — короткая головоломка на один жест. Накорми двух гостей. Без аккаунта, рекламы и слежки.",
            .ukrainian: "Split Picnic — коротка головоломка на один жест. Нагодуй двох гостей. Без акаунта, реклами і стеження.",
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
        case (.pineapple, .english): "pineapple"
        case (.pineapple, .russian): "ананас"
        case (.pineapple, .ukrainian): "ананас"
        case (.onion, .english): "red onion"
        case (.onion, .russian): "красный лук"
        case (.onion, .ukrainian): "червону цибулю"
        case (.corn, .english): "corn"
        case (.corn, .russian): "кукурузу"
        case (.corn, .ukrainian): "кукурудзу"
        case (.mozzarella, .english): "mozzarella"
        case (.mozzarella, .russian): "моцареллу"
        case (.mozzarella, .ukrainian): "моцарелу"
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

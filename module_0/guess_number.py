import numpy as np


def game_core_v1(number: int, top_limit: int) -> int:
    """
    Просто угадываем на random, никак не используя информацию о больше или меньше.
    Функция принимает загаданное число и возвращает число попыток
    :param int number: Загаданное число
    :param int top_limit: Верхний предел загаданного числа
    :return int: Количество попыток понадобившихся, что бы угадать загаданое число
    """
    count = 0
    while True:
        count += 1
        predict = np.random.randint(1, top_limit + 1)  # предполагаемое число
        if number == predict:
            return count                     # выход из цикла, если угадали


def game_core_v2(number: int, top_limit: int) -> int:
    """
    Сначала устанавливаем любое random число, а потом уменьшаем или увеличиваем его в зависимости от того,
    больше оно или меньше нужного. Функция принимает загаданное число и возвращает число попыток
    :param int number: Загаданное число
    :param int top_limit: Верхний предел загаданного числа
    :return int: Количество попыток понадобившихся, что бы угадать загаданое число
    """
    count = 1
    predict = np.random.randint(1, top_limit + 1)
    while number != predict:
        count += 1
        if number > predict:
            predict += 1
        elif number < predict:
            predict -= 1

    # выход из цикла, если угадали
    return count


def game_core_v3(number: int, top_limit: int) -> int:
    """
    Сначала устанавливаем любое random число, а потом уменьшаем или увеличиваем его в зависимости от того,
    больше оно или меньше нужного. Увеличение идёт с использованием алгоритма бинарного поиска. С каждым разом
    зона поиска уменьшается в два раза, до тех пор пока не достигнет значения 1.
    Функция принимает загаданное число и возвращает число попыток
    :param int number: Загаданное число
    :param int top_limit: Верхний предел загаданного числа
    :return int: Количество попыток понадобившихся, что бы угадать загаданое число
    """
    count = 1
    predict = top_limit // 2
    suggested_diff = predict // 2

    """Воткнул inline comments видя, что вы ими активно пользуетесь, хотя PEP8 не приветствует"""
    while number != predict:
        count += 1
        if predict < number:
            predict += suggested_diff                   # увеличиваем предпологаемое число на уменьшенный вдвое шаг
        elif predict > number:
            predict -= suggested_diff                   # уменьшаем предпологаемое число на уменьшенный вдвое шаг
        if suggested_diff > 1:
            suggested_diff = suggested_diff // 2  # уменьшаем шаг вдвое если шаг > 1

    # выход из цикла, если угадали
    return count


def score_game(game_core, top_limit):
    """
    Запускаем игру 1000 раз, чтобы узнать, как быстро игра угадывает число
    :param obj game_core:
    :param int top_limit: Верхний предел загаданного числа
    :return int:
    """
    count_ls = []
    np.random.seed(1)  # фиксируем RANDOM SEED, чтобы ваш эксперимент был воспроизводим!
    random_array = np.random.randint(1, top_limit + 1, size=1000)
    for number in random_array:
        count_ls.append(game_core(number, top_limit))
    score = int(np.mean(count_ls))
    print(f"Ваш алгоритм угадывает число в среднем за {score} попыток")
    return score


TOP_LIMIT = 1000

score_game(game_core_v1, TOP_LIMIT)
score_game(game_core_v2, TOP_LIMIT)
score_game(game_core_v3, TOP_LIMIT)

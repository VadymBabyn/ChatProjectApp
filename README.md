# ChatProject

## Опис

ChatProject — це серверна частина чату, побудована з використанням **Vapor** (Swift) та інтеграцією з OpenAI API. Сервер надає функціонал для створення чатів, обміну повідомленнями та отримання відповідей від ChatGPT.

## Зміст

- [Передумови](#Передумови)
- [Установка](#Установка)
- [Запуск](#Запуск)
- [Міграції](#Міграції)
- [Налаштування бази](#Тестування)
- [Конфігурація](#Конфігурація)

---

## Передумови

Перед початком роботи переконайтеся, що у вас встановлено наступне:

1. **Swift 5.8+**
2. **Vapor Toolbox**
   ```bash
   brew install vapor
3. **PostgreSQL 13+**
Сервер баз даних повинен працювати локально або бути доступним для з'єднання.
4. ***Docker** (опціонально для ізольованого середовища)

  ## Установка
1. Клонування репозиторію
bash

- git clone https://github.com/VadymBabyn/chatproject.git
- cd chatproject

2. Встановлення залежностей
Завантажте всі необхідні пакети:

при роботі через докер:
- docker run -v "Шлях до папки в якій зберігається серверна частина":/app -p 8080:8080 -it --name chatproject-container swift:latest /bin/bash
- cd app
- cd chatproject
- swift package resolve
    ## Запуск
1. Налаштування конфігурацій
в корені проекту створити файл Secrets.json
та добавити текст в форматі
##
{
    "openai_api_key": "your-api-key"
}
##

## Налаштування бази
цей проект налаштовано під базу яка знаходиться на локальному комп'ютері, а проект запускається через докер.
в базі postgreSQL потрібно мати 
Database під назвою chatdatabase

## Створення міграцій

для міграції таблиць потрібно знаходитись в папкі
app\chatproject   (в докер контейнері)
swift build  
swift run App migrate

## Запуск сервера

swift run App


Цей файл README детально описує всі етапи від налаштування середовища до запуску проекту.
//
//  ViewController.swift
//  iQuiz
//
//  Created by An Nguyen on 5/6/25.
//

import UIKit
import Network

struct Answer {
    let text: String
    let isCorrect: Bool
}

struct Question {
    let text: String
    let answers: [Answer]
    var correctAnswerIndex: Int {
        return answers.firstIndex(where: { $0.isCorrect }) ?? 0
    }
}

struct QuizCategory {
    let id: String
    let name: String
    let image: String
    let description: String
    var questions: [Question] = []
    
    init(id: String, name: String, image: String, description: String, questions: [Question] = []) {
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.questions = questions
    }
    
    init(dictionary: [String: String]) {
        self.id = dictionary["id"] ?? UUID().uuidString
        self.name = dictionary["name"] ?? ""
        self.image = dictionary["image"] ?? ""
        self.description = dictionary["description"] ?? ""
        self.questions = []
    }
}

struct QuizData: Codable {
    let title: String
    let desc: String
    let questions: [QuestionData]
    
    struct QuestionData: Codable {
        let text: String
        let answer: String
        let answers: [String]
    }
    
}

class TableViewController: UITableViewController {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var quizCategories: [QuizCategory] = []
    
    var jsonUrl: URL? {
        get {
            if let urlString = UserDefaults.standard.string(forKey: "CustomQuizURL"),
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                return url
            }
            return URL(string: "http://tednewardsandbox.site44.com/questions.json")
        }
    }
    
    private var pathMonitor: NWPathMonitor?
    private var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkMonitoring()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc func userDefaultsDidChange(_ notification: Notification) {
        if UIApplication.shared.applicationState == .active {
            loadQuizCategoriesFromJSON()
        }
    }
    
    func setupNetworkMonitoring() {
        pathMonitor = NWPathMonitor()
        isConnected = false
        
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? false
                self?.isConnected = connected
                print("Network connection status: \(connected ? "Connected" : "Disconnected")")
                if !wasConnected && connected {
                    self?.loadQuizCategoriesFromJSON()
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        pathMonitor?.start(queue: queue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadQuizCategoriesFromJSON()
        }
    }
    
    deinit {
        pathMonitor?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadQuizCategoriesFromJSON() {
        if !isConnected {
            print("No network connection. Using local data instead.")
            if let localCategories = loadQuizzesFromLocalStorage() {
                quizCategories = localCategories
                tableView.reloadData()
                print("Loaded quiz data from local storage while offline")
            } else {
                print("No local storage data found, using hardcoded data")
                loadQuizCategories()
            }
            return
        }
        
        guard let url = jsonUrl else {
            print("Invalid URL")
            loadQuizCategories()
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching data: \(error)")
                    self.handleDataLoadError(message: "Failed to load quiz data. Using local data instead.")
                    return
                }
                
                guard let data = data else {
                    print("No data returned")
                    self.handleDataLoadError(message: "No quiz data received. Using local data instead.")
                    return
                }
                
                do {
                    let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                    guard let jsonArray = jsonArray else {
                        print("Invalid JSON format")
                        self.handleDataLoadError(message: "Invalid quiz data format. Using local data instead.")
                        return
                    }
                    self.processJSONData(jsonArray)
                    self.saveQuizzesToLocalStorage()
                } catch {
                    print("JSON parsing error: \(error)")
                    self.handleDataLoadError(message: "Error parsing quiz data. Using local data instead.")
                }
            }
        }
        task.resume()
    }
    
    func processJSONData(_ jsonArray: [[String: Any]]) {
        var categories: [QuizCategory] = []
        
        for (index, categoryData) in jsonArray.enumerated() {
            let id = "category_\(index)"
            let title = categoryData["title"] as? String ?? "Unknown Category \(index)"
            let description = categoryData["desc"] as? String ?? "No description provided."
            let image = getCategoryImage(for: title)
            var category = QuizCategory(id: id, name: title, image: image, description: description)
            
            if let questionsData = categoryData["questions"] as? [[String: Any]] {
                var questions: [Question] = []
                
                for questionData in questionsData {
                    let questionText = questionData["text"] as? String ?? "Unknown Question"
                    let correctAnswerString = questionData["answer"] as? String ?? "1"
                    let correctAnswerIndex = Int(correctAnswerString) ?? 1
                    let answersArray = questionData["answers"] as? [String] ?? []
                    
                    var answers: [Answer] = []
                    
                    for (index, answerText) in answersArray.enumerated() {
                        let isCorrect = (index + 1) == correctAnswerIndex
                        answers.append(Answer(text: answerText, isCorrect: isCorrect))
                    }
                    
                    let question = Question(text: questionText, answers: answers)
                    questions.append(question)
                }
                category.questions = questions
            }
            categories.append(category)
        }
        quizCategories = categories
        tableView.reloadData()
    }
    
    func getCategoryImage(for title: String) -> String {
        switch title {
        case "Mathematics":
            return "math-logo"
        case "Marvel Super Heroes":
            return "marvel-avengers-logo"
        case "Science!":
            return "science-logo"
        default:
            return "default-logo"
        }
    }
    
    func handleDataLoadError(message: String) {
        if let localCategories = loadQuizzesFromLocalStorage() {
            quizCategories = localCategories
            tableView.reloadData()
            print("Loading from local storage")
        } else {
            showErrorAlert(message: message)
            loadQuizCategories()
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                     message: message,
                                     preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func saveQuizzesToLocalStorage() {
        do {
            let quizDataArray = quizCategories.map { category -> QuizData in
                let questionDataArray = category.questions.map { question -> QuizData.QuestionData in
                    let correctAnswerIndex = question.correctAnswerIndex + 1
                    let answerTexts = question.answers.map { $0.text }
                    
                    return QuizData.QuestionData(
                        text: question.text,
                        answer: "\(correctAnswerIndex)",
                        answers: answerTexts
                    )
                }
                
                return QuizData(
                    title: category.name,
                    desc: category.description,
                    questions: questionDataArray
                )
            }
            
            let jsonData = try JSONEncoder().encode(quizDataArray)
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("quizzes.json")
            try jsonData.write(to: fileURL)
            print("Successfully saved quizzes to: \(fileURL.path)")
        } catch {
            print("Error saving quizzes: \(error.localizedDescription)")
        }
    }
    
    func loadQuizzesFromLocalStorage() -> [QuizCategory]? {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("quizzes.json")
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("No local quizzes file found")
                return nil
            }
            
            let jsonData = try Data(contentsOf: fileURL)
            let quizDataArray = try JSONDecoder().decode([QuizData].self, from: jsonData)
            let categories = quizDataArray.enumerated().map { (index, quizData) -> QuizCategory in
                let id = "category_\(index)"
                let image = self.getCategoryImage(for: quizData.title)
                var category = QuizCategory(id: id, name: quizData.title, image: image, description: quizData.desc)
                
                let questions = quizData.questions.map { questionData -> Question in
                    let correctAnswerIndex = Int(questionData.answer) ?? 1
                    let answers = questionData.answers.enumerated().map { (index, text) -> Answer in
                        let isCorrect = (index + 1) == correctAnswerIndex
                        return Answer(text: text, isCorrect: isCorrect)
                    }
                    return Question(text: questionData.text, answers: answers)
                }
                
                category.questions = questions
                return category
            }
            print("Successfully loaded quizzes from local storage")
            return categories
        } catch {
            print("Error loading quizzes from local storage: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadQuizCategories() {
        let categoriesData : [[String: String]] = [
            [
                "id": "math",
                "name": "Mathematics",
                "image": "math-logo",
                "description": "Learn about the universal language of numbers and patterns."
            ], [
                "id": "marvel",
                "name": "Marvel Super Heroes",
                "image": "marvel-avengers-logo",
                "description": "Test your knowledge of Earth's mightiest heroes."
            ], [
                "id": "science",
                "name": "Science",
                "image": "science-logo",
                "description": "Explore the wonders of our natural world."
            ]
        ]
        quizCategories = categoriesData.map { QuizCategory(dictionary: $0) }
        loadQuestions()
    }
    
    func loadQuestions() {
        for i in 0..<quizCategories.count {
            switch quizCategories[i].id {
                case "math":
                    quizCategories[i].questions = createMathQuestions()
                case "marvel":
                    quizCategories[i].questions = createMarvelQuestions()
                case "science":
                    quizCategories[i].questions = createScienceQuestions()
                default:
                    quizCategories[i].questions = []
            }
        }
    }

    func createMathQuestions() -> [Question] {
        return [
            Question(
                text: "What is 2 + 2?",
                answers: [
                    Answer(text: "3", isCorrect: false),
                    Answer(text: "4", isCorrect: true),
                    Answer(text: "5", isCorrect: false),
                    Answer(text: "6", isCorrect: false)
                ]
            ),
            Question(
                text: "What is 7 × 8?",
                answers: [
                    Answer(text: "54", isCorrect: false),
                    Answer(text: "56", isCorrect: true),
                    Answer(text: "64", isCorrect: false),
                    Answer(text: "48", isCorrect: false)
                ]
            ),
            Question(
                text: "What is the square root of 144?",
                answers: [
                    Answer(text: "10", isCorrect: false),
                    Answer(text: "12", isCorrect: true),
                    Answer(text: "14", isCorrect: false),
                    Answer(text: "16", isCorrect: false)
                ]
            )
        ]
    }
    
    func createMarvelQuestions() -> [Question] {
        return [
            Question(
                text: "Who is Iron Man?",
                answers: [
                    Answer(text: "Tony Stark", isCorrect: true),
                    Answer(text: "Steve Rogers", isCorrect: false),
                    Answer(text: "Bruce Banner", isCorrect: false),
                    Answer(text: "Thor", isCorrect: false)
                ]
            ),
            Question(
                text: "What is Captain America's shield made of?",
                answers: [
                    Answer(text: "Steel", isCorrect: false),
                    Answer(text: "Adamantium", isCorrect: false),
                    Answer(text: "Vibranium", isCorrect: true),
                    Answer(text: "Titanium", isCorrect: false)
                ]
            ),
            Question(
                text: "Who is Thor's brother?",
                answers: [
                    Answer(text: "Odin", isCorrect: false),
                    Answer(text: "Loki", isCorrect: true),
                    Answer(text: "Heimdall", isCorrect: false),
                    Answer(text: "Balder", isCorrect: false)
                ]
            )
        ]
    }
    
    func createScienceQuestions() -> [Question] {
        return [
            Question(
                text: "What is the chemical symbol for water?",
                answers: [
                    Answer(text: "O", isCorrect: false),
                    Answer(text: "W", isCorrect: false),
                    Answer(text: "H2O", isCorrect: true),
                    Answer(text: "WTR", isCorrect: false)
                ]
            ),
            Question(
                text: "What planet is known as the Red Planet?",
                answers: [
                    Answer(text: "Earth", isCorrect: false),
                    Answer(text: "Venus", isCorrect: false),
                    Answer(text: "Mars", isCorrect: true),
                    Answer(text: "Jupiter", isCorrect: false)
                ]
            ),
            Question(
                text: "What is the largest organ in the human body?",
                answers: [
                    Answer(text: "Heart", isCorrect: false),
                    Answer(text: "Liver", isCorrect: false),
                    Answer(text: "Brain", isCorrect: false),
                    Answer(text: "Skin", isCorrect: true)
                ]
            )
        ]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizCategories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTopicCell", for: indexPath)
        
        if let imageView = cell.viewWithTag(1) as? UIImageView,
           let titleLabel = cell.viewWithTag(2) as? UILabel,
           let descriptionLabel = cell.viewWithTag(3) as? UILabel {
            
            let category = quizCategories[indexPath.row]
            
            imageView.image = UIImage(named: category.image)
            titleLabel.text = category.name
            descriptionLabel.text = category.description
            
            imageView.contentMode = .scaleAspectFit
        } else {
            print("Image view not found")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "StartQuizSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartQuizSegue" {
            if let destinationViewController = segue.destination as? QuizViewController,
               let indexPath = tableView.indexPathForSelectedRow {
                let selectedCategory = quizCategories[indexPath.row]
                destinationViewController.category = selectedCategory
                destinationViewController.title = selectedCategory.name
            }
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        } else {
            showErrorAlert(message: "Could not open Settings app.")
        }
    }
    
    @IBAction func UnwindToTableView(_ unwindSegue: UIStoryboardSegue) {
    }
}

//
//  ViewController.swift
//  iQuiz
//
//  Created by An Nguyen on 5/6/25.
//

import UIKit

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

class TableViewController: UITableViewController {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var quizCategories: [QuizCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadQuizCategories()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        let alert = UIAlertController(title: "Settings",
                                     message: "Settings go here",
                                     preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func UnwindToTableView(_ unwindSegue: UIStoryboardSegue) {
    }
}

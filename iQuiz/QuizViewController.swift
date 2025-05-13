//
//  QuizViewController.swift
//  iQuiz
//
//  Created by An Nguyen on 5/12/25.
//

import UIKit

class QuizViewController: UIViewController {
    
    var category: QuizCategory!
    var currentQuestionIndex = 0
    var userScore = 0
    var selectedAnswerIndex: Int? = nil
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionCountLabel: UILabel!
    @IBOutlet weak var answersTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayCurrentQuestion()
        submitButton.isEnabled = false
    }
    
    private func setupUI() {
        title = category.name
        categoryLabel.text = category.name
        answersTableView.delegate = self
        answersTableView.dataSource = self
    }
    
    private func displayCurrentQuestion() {
        selectedAnswerIndex = nil
        submitButton.isEnabled = false
        
        print(currentQuestionIndex)
        print(category.questions.count)
        let currentQuestion = category.questions[currentQuestionIndex]
        questionLabel.text = currentQuestion.text
        questionCountLabel.text = "Question \(currentQuestionIndex + 1) of \(category.questions.count)"
        answersTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAnswerSegue" {
            guard let selectedIndex = selectedAnswerIndex,
                  let answerVC = segue.destination as? AnswerViewController else { return }
            
            let question = category.questions[currentQuestionIndex]
            let isCorrect = question.answers[selectedIndex].isCorrect
            
            if isCorrect {
                userScore += 1
            }
            
            answerVC.question = question
            answerVC.category = category
            answerVC.isCorrect = isCorrect
            answerVC.currentQuestionIndex = currentQuestionIndex
            answerVC.totalQuestions = category.questions.count
            answerVC.userScore = userScore
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if selectedAnswerIndex == nil {
            let alert = UIAlertController(title: "No Answer Selected",
                                         message: "Please select an answer before submitting.",
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

extension QuizViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard currentQuestionIndex < category.questions.count else { return 0 }
        return category.questions[currentQuestionIndex].answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
                
        let answer = category.questions[currentQuestionIndex].answers[indexPath.row]
        cell.textLabel?.text = answer.text
        
        if let selectedIndex = selectedAnswerIndex, selectedIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedAnswerIndex = indexPath.row
        submitButton.isEnabled = true
        tableView.reloadData()
    }
}

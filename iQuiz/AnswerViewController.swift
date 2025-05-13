//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by An Nguyen on 5/12/25.
//

import UIKit

class AnswerViewController: UIViewController {
    
    var question: Question!
    var category: QuizCategory!
    var isCorrect: Bool = false
    var currentQuestionIndex: Int = 0
    var totalQuestions: Int = 0
    var userScore: Int = 0
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryLabel.text = category.name
        questionNumberLabel.text = "Question \(currentQuestionIndex + 1) of \(category.questions.count)"
        questionLabel.text = question.text
        
        if isCorrect {
            resultLabel.text = "Correct!"
            resultLabel.textColor = UIColor.systemGreen
        } else {
            resultLabel.text = "Incorrect"
            resultLabel.textColor = UIColor.systemRed
        }
        
        correctAnswerLabel.text = "The correct answer is: \(question.answers[question.correctAnswerIndex].text)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextQuestionSegue" {
            if let quizVC = segue.destination as? QuizViewController {
                quizVC.category = category
                quizVC.currentQuestionIndex = currentQuestionIndex + 1
                quizVC.userScore = userScore
            }
        } else if segue.identifier == "ShowResultsSegue" {
            if let resultsVC = segue.destination as? ResultsViewController {
                resultsVC.category = category.name
                resultsVC.score = userScore
                resultsVC.totalQuestions = totalQuestions
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if currentQuestionIndex + 1 < totalQuestions {
            performSegue(withIdentifier: "NextQuestionSegue", sender: self)
        } else {
            performSegue(withIdentifier: "ShowResultsSegue", sender: self)
        }
    }
}

//
//  ResultsViewController.swift
//  iQuiz
//
//  Created by An Nguyen on 5/12/25.
//

import UIKit

class ResultsViewController: UIViewController {
    
    var score: Int = 0
    var totalQuestions: Int = 0
    var category: String = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryLabel.text = category
        let percentage = Double(score) / Double(totalQuestions) * 100
        
        if percentage == 100 {
            titleLabel.text = "Perfect!"
        } else if percentage >= 80 {
            titleLabel.text = "Great Job!"
        } else if percentage >= 60 {
            titleLabel.text = "Good Effort!"
        } else if percentage >= 40 {
            titleLabel.text = "Not Bad!"
        } else {
            titleLabel.text = "Keep Trying!"
        }
        
        scoreLabel.text = "You scored \(score) out of \(totalQuestions) (\(Int(percentage))%)"
    }
}

//
//  ViewController.swift
//  iQuiz
//
//  Created by An Nguyen on 5/6/25.
//

import UIKit

class ViewController: UITableViewController {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    let quizCategories : [[String: String]] = [
        [
            "name": "Mathematics",
            "image": "math-logo",
            "description": "Learn about the universal language of numbers and patterns."
        ], [
            "name": "Marvel Super Heroes",
            "image": "marvel-avengers-logo",
            "description": "Test your knowledge of Earth's mightiest heroes."
        ], [
            "name": "Science",
            "image": "science-logo",
            "description": "Explore the wonders of our natural world."
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            
            imageView.image = UIImage(named: category["image"] ?? "")
            titleLabel.text = category["name"]
            descriptionLabel.text = category["description"]
            
            imageView.contentMode = .scaleAspectFit
        } else {
            print("Image view not found")
        }
        
        return cell
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Settings",
                                     message: "Settings go here",
                                     preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}


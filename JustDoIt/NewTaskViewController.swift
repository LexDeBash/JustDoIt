//
//  NewTaskViewController.swift
//  JustDoIt
//
//  Created by Alexey Efimov on 13.04.2021.
//

import UIKit

class NewTaskViewController: UIViewController {

    @IBOutlet var taskTextView: UITextView!
    @IBOutlet var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func doneButtonPressed() {
    }
    
    @IBAction func cancelButtonPressed() {
    }
}

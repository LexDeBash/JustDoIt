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
    
    var task: Task?
    
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        setupTextView()
    }

    @IBAction func doneButtonPressed() {
        guard let title = taskTextView.text, !title.isEmpty else { return }
        let priority = Int16(prioritySegmentedControl.selectedSegmentIndex)
        if let task = task {
            storageManager.edit(task: task, with: title, and: priority)
        } else {
            storageManager.saveTask(withTitle: title, andPriority: priority)
        }
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    private func setupTextView() {
        taskTextView.textColor = .white
        taskTextView.becomeFirstResponder()
        if let task = task {
            taskTextView.text = task.title
            prioritySegmentedControl.selectedSegmentIndex = Int(task.priority)
        } else {
            doneButton.isHidden = true
        }
    }
}

// MARK: - Text view delegate
extension NewTaskViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if doneButton.isHidden {
            textView.text.removeAll()
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Work with keyboard
extension NewTaskViewController {
    @objc private func keyboardWillShow(with notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else { return }
        bottomConstraint.constant = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

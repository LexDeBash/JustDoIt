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
    
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isHidden = true
        taskTextView.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    @IBAction func doneButtonPressed() {
        guard let title = taskTextView.text, !title.isEmpty else { return }
        let priority = Int16(prioritySegmentedControl.selectedSegmentIndex)
        
        storageManager.saveTask(withTitle: title, andPriority: priority)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss(animated: true)
    }
}

// MARK: - Text view delegate
extension NewTaskViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
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

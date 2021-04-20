//
//  TaskListViewController.swift
//  JustDoIt
//
//  Created by Alexey Efimov on 09.04.2021.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private var fetchedResulstController = StorageManager.shared.fetchedResultsController(
        entityName: "Task",
        keysForSort: ["isComplete", "date"]
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        fetchedResulstController.delegate = self
        
        do {
            try fetchedResulstController.performFetch()
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask" {
            guard let newTaskVC = segue.destination as? NewTaskViewController else { return }
            newTaskVC.task = sender as? Task
        }
    }
}

// MARK: - Table View Data Soutce
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResulstController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let task = getTask(at: indexPath)
        cell.contentConfiguration = setContentForCell(with: task)
        return cell
    }
}

// MARK: - Table View Delegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            if let task = self.getTask(at: indexPath) {
                StorageManager.shared.delete(task: task)
            }
        }
        
        deleteAction.image = #imageLiteral(resourceName: "Trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, isDone) in
            if let task = self.getTask(at: indexPath) {
                StorageManager.shared.done(task: task)
            }
            isDone(true)
        }
        
        doneAction.image = #imageLiteral(resourceName: "Check")
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = getTask(at: indexPath)
        performSegue(withIdentifier: "editTask", sender: task)
    }
}

// MARK: - NSFetchResultsControllerDelegate
extension TaskListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            let cell = tableView.cellForRow(at: indexPath)
            let task = getTask(at: newIndexPath)
            cell?.contentConfiguration = setContentForCell(with: task)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default: break
        }
    }
}

// MARK: - Private Methods
extension TaskListViewController {
    private func setupNavigationBar() {
        let fontName = "Apple SD Gothic Neo Bold"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
       
        navBarAppearance.titleTextAttributes = [
            .font: UIFont(name: fontName, size: 19) ?? UIFont.systemFont(ofSize: 19),
            .foregroundColor: UIColor.white
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .font: UIFont(name: fontName, size: 35) ?? UIFont.systemFont(ofSize: 35),
            .foregroundColor: UIColor.white
        ]
        navBarAppearance.backgroundColor = UIColor(
            red: 97/255,
            green: 210/255,
            blue: 255/255,
            alpha: 255/255
        )

        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    private func setContentForCell(with task: Task?) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.cell()
        
        content.textProperties.font = UIFont(
            name: "Avenir Next Medium", size: 23
        ) ?? UIFont.systemFont(ofSize: 23)
        
        content.textProperties.color = .darkGray
        content.text = task?.title
        content.attributedText = strikeThrough(string: task?.title ?? "", task?.isComplete ?? false)

        return content
    }
    
    private func strikeThrough(string: String, _ isStrikeThrough: Bool) -> NSAttributedString {
        var attributedString = NSAttributedString(
            string: string,
            attributes: [NSAttributedString.Key.strikethroughStyle : 0]
        )
        
        if isStrikeThrough {
            attributedString = NSAttributedString(
                string: string,
                attributes: [
                    NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.double.rawValue
                ]
            )
        }
        return attributedString
    }
    
    private func getTask(at indexPath: IndexPath?) -> Task? {
        if let indexPath = indexPath {
            return fetchedResulstController.object(at: indexPath) as? Task
        }
        return nil
    }
}

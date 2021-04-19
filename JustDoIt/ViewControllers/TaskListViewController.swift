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
        keyForSort: "date"
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
        guard let task = fetchedResulstController.object(at: indexPath) as? Task else { return cell }
        cell.contentConfiguration = setContentForCell(with: task)
        return cell
    }
}

// MARK: - Table View Delegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            if let task = self.fetchedResulstController.object(at: indexPath) as? Task {
                StorageManager.shared.delete(task: task)
            }
        }
        
        deleteAction.image = #imageLiteral(resourceName: "Trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let task = fetchedResulstController.object(at: indexPath) as? Task else { return }
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
        guard let indexPath = indexPath else { return }
        guard let newIndexPath = newIndexPath else { return }
        guard let task = fetchedResulstController.object(at: indexPath) as? Task else { return }
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath)
            cell?.contentConfiguration = setContentForCell(with: task)
        case .delete:
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
    
    private func setContentForCell(with task: Task) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.cell()
        
        content.textProperties.font = UIFont(
            name: "Avenir Next Medium", size: 23
        ) ?? UIFont.systemFont(ofSize: 23)
        
        content.textProperties.color = .darkGray
        content.text = task.title

        return content
    }
}

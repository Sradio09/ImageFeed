import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }

    func viewDidLoad()
    func didTapLogout()
}


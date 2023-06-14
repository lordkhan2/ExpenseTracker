//
//  ChatBotViewController.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 13/6/2023.
//

import UIKit
import SwiftUI

class ChatBotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an instance of the SwiftUI view
        let mySwiftUIView = ChatBotSwiftUIView()

        // Create a hosting controller to embed the SwiftUI view
        let hostingController = UIHostingController(rootView: mySwiftUIView)

        // Add the hosting controller's view as a subview
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }

}

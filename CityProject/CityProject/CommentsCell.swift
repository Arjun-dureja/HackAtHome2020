//
//  CommentsCell.swift
//  CityProject
//
//  Created by Arjun Dureja on 2020-05-02.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

protocol CommentsCellDelegate {
    func didTapSave(comment: String?)
}

class CommentsCell: UITableViewCell {
    @IBOutlet var comments: UITextView!
    var delegate: CommentsCellDelegate?
    
    @IBAction func saveTapped(_ sender: Any) {
        delegate?.didTapSave(comment: comments.text)
    }
}

extension UITextView {
    
    func addDoneButton(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}

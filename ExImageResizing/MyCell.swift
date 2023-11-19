//
//  MyCell.swift
//  ExImageResizing
//
//  Created by 김종권 on 2023/11/19.
//

import UIKit

struct MyModel {
    let text: String
    let image: UIImage?
}

final class MyTableViewCell: UITableViewCell {
    static let id = "MyTableViewCell"
    
    // MARK: UI
    private let label = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let myImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Initializer
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
        
        contentView.addSubview(myImageView)
        NSLayoutConstraint.activate([
            myImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            myImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            myImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            myImageView.widthAnchor.constraint(equalToConstant: 120),
            myImageView.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    func prepare(model: MyModel) {
        label.text = model.text
        myImageView.image = model.image
    }
}


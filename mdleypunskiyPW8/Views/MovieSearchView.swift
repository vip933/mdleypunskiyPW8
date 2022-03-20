//
//  MovieSearchView.swift
//  mdleypunskiyPW8
//
//  Created by Maksim on 20.03.2022.
//

import UIKit

class MovieSearchView: UIView {
    static let imageHeight = 200
    static let titleHeight = 20
    static let indentHeight = 10
    private let poster = UIImageView()
    private let title = UILabel()
    
    init() {
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        poster.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(poster)
        addSubview(title)
        
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: topAnchor),
            poster.leadingAnchor.constraint(equalTo: leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: trailingAnchor),
            poster.heightAnchor.constraint(equalToConstant: CGFloat(Self.imageHeight)),
            
            title.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: CGFloat(Self.indentHeight)),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            title.heightAnchor.constraint(equalToConstant: CGFloat(Self.titleHeight)),
        ])
        title.textAlignment = .center
    }
    
    func configure(movie: Movie) {
        title.text = movie.title
        poster.image = movie.poster
    }
}

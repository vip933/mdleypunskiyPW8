//
//  ViewController.swift
//  mdleypunskiyPW8
//
//  Created by Maksim on 19.03.2022.
//

import UIKit

class MoviesViewController: UIViewController {
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies()
        }
    }
    
    private func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.reloadData()
    }
    
    private func loadMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/550?api_key=\(Constants.shared.apiKey)&language=ruRu") else {
            return assertionFailure("Problems with url!")
            
        }
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { data, _, _ in
            
        })
        
        session.resume()
    }
}

extension MoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MovieView()
    }
}


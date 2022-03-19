//
//  ViewController.swift
//  mdleypunskiyPW8
//
//  Created by Maksim on 19.03.2022.
//

import UIKit

class MoviesViewController: UIViewController {
    private let tableView = UITableView()
    private var movies: [Movie] = []
    
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
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.ident)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = CGFloat(MovieView.imageHeight + MovieView.titleHeight + 2 * MovieView.indentHeight)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.reloadData()
    }
    
    private func loadMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(Constants.shared.apiKey)&language=ruRu") else {
            return assertionFailure("Problems with url!")
            
        }
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { [weak self] data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let result = dict["results"] as? [[String: Any]]
            else {
                return
            }
            
            let movies: [Movie] = result.map { params -> Movie in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as! String
                return Movie(
                    title: title,
                    posterPath: imagePath
                )
            }
            
            self?.loadImagesForMovies(movies) { movies in
                self?.movies = movies
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
        
        session.resume()
    }
    
    private func loadImagesForMovies(_ movies: [Movie], completion: @escaping ([Movie]) -> Void) {
        let group = DispatchGroup()
        for movie in movies {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                movie.loadPoster { _ in
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(movies)
        }
    }
}

extension MoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.ident, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}


//
//  SearchViewController.swift
//  mdleypunskiyPW8
//
//  Created by Maksim on 19.03.2022.
//

import UIKit

class SearchViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        confiqureUI()
        setupTapGestures()
    }
    
    private func confiqureUI() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.ident)
        tableView.rowHeight = CGFloat(MovieView.imageHeight + MovieView.titleHeight + 2 * MovieView.indentHeight)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.reloadData()
    }
    
    private func setupTapGestures() {
        let tapRecogniser = UITapGestureRecognizer()
        tapRecogniser.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecogniser)
    }
    
    @objc
    private func didTapView(){
        self.view.endEditing(true)
    }
    
    private var session: URLSessionDataTask?
    private func loadMovies(request: String) {
        let finalRequest = request.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(Constants.shared.apiKey)&query=\(finalRequest)") else {
            return
        }
        self.session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { [weak self] data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let result = dict["results"] as? [[String: Any]]
            else {
                return
            }
            
            let movies: [Movie] = result.map { params -> Movie in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as? String
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
        
        session?.resume()
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

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.ident, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if session?.state == URLSessionDataTask.State.running {
            session?.cancel()
        }
        guard let request = searchBar.text else { return  }
        setupMovies(request: request)
    }
    
    private func setupMovies(request: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(request: request)
        }
    }
}

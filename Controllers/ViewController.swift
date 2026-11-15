//
//  ViewController.swift
//  MukhMusic
//
//  Created by Muxtar Babazade on 01.11.26.
//

import UIKit

enum MukhTheme {
    static let background = UIColor(red: 0.035, green: 0.043, blue: 0.063, alpha: 1)
    static let surface = UIColor(red: 0.090, green: 0.105, blue: 0.140, alpha: 1)
    static let primaryText = UIColor(red: 0.950, green: 0.960, blue: 0.980, alpha: 1)
    static let secondaryText = UIColor(red: 0.620, green: 0.680, blue: 0.750, alpha: 1)
    static let accent = UIColor(red: 0.710, green: 0.940, blue: 0.450, alpha: 1)
}

final class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!

    private let searchBar = UISearchBar()
    private let emptyStateLabel = UILabel()
    private var apiKey: String? {
        ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"]
    }

    var songs: [Song] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        view.backgroundColor = MukhTheme.background
        configureNavigationBar()
        configureTableView()
        configureSearchBar()
    }

    private func configureNavigationBar() {
        navigationItem.title = "MukhMusic"
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = MukhTheme.background
        appearance.titleTextAttributes = [.foregroundColor: MukhTheme.primaryText]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: MukhTheme.primaryText,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = MukhTheme.accent
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = MukhTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = 78
        tableView.estimatedRowHeight = 78
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)

        emptyStateLabel.text = "Search for a song or artist\nto get started"
        emptyStateLabel.textColor = MukhTheme.secondaryText
        emptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        tableView.backgroundView = emptyStateLabel
        updateEmptyState()
    }

    private func configureSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Songs, artists, or moods"
        searchBar.delegate = self
        searchBar.tintColor = MukhTheme.accent
        searchBar.searchTextField.backgroundColor = MukhTheme.surface
        searchBar.searchTextField.textColor = MukhTheme.primaryText
        searchBar.searchTextField.layer.cornerRadius = 14
        searchBar.searchTextField.clipsToBounds = true
        searchBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 62)
        tableView.tableHeaderView = searchBar
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let song = songs[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = song.title
        content.secondaryText = song.artist
        content.image = UIImage(systemName: "music.note")
        content.imageProperties.tintColor = MukhTheme.accent
        content.textProperties.color = MukhTheme.primaryText
        content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        content.secondaryTextProperties.color = MukhTheme.secondaryText
        content.secondaryTextProperties.font = .systemFont(ofSize: 13, weight: .regular)
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 12)
        cell.contentConfiguration = content

        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = MukhTheme.surface
        background.cornerRadius = 16
        background.backgroundInsets = NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16)
        cell.backgroundConfiguration = background
        cell.backgroundColor = .clear
        cell.tintColor = MukhTheme.accent
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityHint = "Opens the selected YouTube video"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedSong = songs[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let playerVC = storyboard.instantiateViewController(
            withIdentifier: "PlayerViewController"
        ) as? PlayerViewController else {
            return
        }

        playerVC.songTitle = selectedSong.title
        playerVC.artistName = selectedSong.artist
        playerVC.videoID = selectedSong.videoId
        navigationController?.pushViewController(playerVC, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty else {
            return
        }

        guard let apiKey, !apiKey.isEmpty else {
            showMessage(
                title: "Add your API key",
                message: "In Xcode, add YOUTUBE_API_KEY to the Run scheme’s Environment Variables. The key stays out of your source files."
            )
            searchBar.resignFirstResponder()
            return
        }

        Task {
            do {
                let results = try await YouTubeSearchService.searchVideos(query: query, apiKey: apiKey)
                songs = results.map { result in
                    Song(
                        title: result.snippet.title,
                        artist: result.snippet.channelTitle,
                        videoId: result.id.videoId
                    )
                }
                updateEmptyState()
                tableView.reloadData()
            } catch {
                showMessage(
                    title: "Search didn’t work",
                    message: "Check your connection and YouTube API key, then try again."
                )
            }
        }

        searchBar.resignFirstResponder()
    }

    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func updateEmptyState() {
        if songs.isEmpty {
            emptyStateLabel.text = searchBar.text?.isEmpty == false
                ? "No results found. Try another search."
                : "Search for a song or artist\nto get started"
            emptyStateLabel.isHidden = false
        } else {
            emptyStateLabel.isHidden = true
        }
    }
}

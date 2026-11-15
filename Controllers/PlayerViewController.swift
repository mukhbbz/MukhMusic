//
//  PlayerViewController.swift
//  MukhMusic
//
//  Created by Muxtar Babazade on 01.11.26.
//

import UIKit
import WebKit

final class PlayerViewController: UIViewController {

    @IBOutlet weak var playerWebView: WKWebView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var openYouTubeButton: UIButton!

    var songTitle: String?
    var artistName: String?
    var videoID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        view.backgroundColor = MukhTheme.background
        navigationItem.title = "Now Playing"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = MukhTheme.accent

        configurePlayerScreen()
        configureYouTubePlayer()
    }

    private func configurePlayerScreen() {
        playerWebView.translatesAutoresizingMaskIntoConstraints = false
        songTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        openYouTubeButton.translatesAutoresizingMaskIntoConstraints = false

        playerWebView.backgroundColor = .black
        playerWebView.isOpaque = false
        playerWebView.layer.cornerRadius = 18
        playerWebView.clipsToBounds = true

        songTitleLabel.text = songTitle
        songTitleLabel.textColor = MukhTheme.primaryText
        songTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        songTitleLabel.numberOfLines = 2

        artistLabel.text = artistName
        artistLabel.textColor = MukhTheme.secondaryText
        artistLabel.font = .systemFont(ofSize: 16, weight: .medium)
        artistLabel.numberOfLines = 1

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.title = "Open in YouTube"
        buttonConfiguration.baseBackgroundColor = MukhTheme.accent
        buttonConfiguration.baseForegroundColor = MukhTheme.background
        buttonConfiguration.cornerStyle = .capsule
        buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 22, bottom: 14, trailing: 22)
        openYouTubeButton.configuration = buttonConfiguration

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            playerWebView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 18),
            playerWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerWebView.heightAnchor.constraint(equalToConstant: 220),

            songTitleLabel.topAnchor.constraint(equalTo: playerWebView.bottomAnchor, constant: 24),
            songTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            songTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 8),
            artistLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: songTitleLabel.trailingAnchor),

            openYouTubeButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 22),
            openYouTubeButton.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            openYouTubeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureYouTubePlayer() {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let videoURL = URL(
                string: "https://www.youtube.com/embed/\(videoID)?playsinline=1"
              ) else {
            return
        }

        var request = URLRequest(url: videoURL)
        request.setValue(
            "https://\(bundleID.lowercased())",
            forHTTPHeaderField: "Referer"
        )
        playerWebView.load(request)
    }

    @IBAction func openVideoTapped(_ sender: Any) {
        guard !videoID.isEmpty,
              let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") else {
            return
        }

        UIApplication.shared.open(url)
    }
}

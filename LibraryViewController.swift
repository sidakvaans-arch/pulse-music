import UIKit
import MediaPlayer
import StoreKit

final class LibraryViewController: UITableViewController, UISearchBarDelegate {
    private let player = MPMusicPlayerController.systemMusicPlayer
    private let searchBar = UISearchBar()
    private var songs: [MPMediaItem] = []
    private var searchResults: [CatalogSong] = []
    private var isSearchingCatalog = false
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pulse Music"
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Now Playing", style: .plain, target: self, action: #selector(showNowPlaying))
        searchBar.placeholder = "Search Apple Music catalog"
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SongCell")
        tableView.rowHeight = 66
        statusLabel.text = "Your Library"
        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = .secondaryLabel
        statusLabel.frame = CGRect(x: 16, y: 0, width: view.bounds.width - 32, height: 34)
        tableView.tableFooterView = UIView()
        requestLibraryAccess()
        player.beginGeneratingPlaybackNotifications()
    }

    deinit { player.endGeneratingPlaybackNotifications() }

    private func requestLibraryAccess() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if status == .authorized {
                    self.songs = MPMediaQuery.songs().items ?? []
                    self.tableView.reloadData()
                } else {
                    self.showMessage("Allow Media & Apple Music access in Settings to see your library.")
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchingCatalog ? searchResults.count : songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if isSearchingCatalog {
            let song = searchResults[indexPath.row]
            cell.textLabel?.text = song.title
            cell.textLabel?.text = "\(song.title) — \(song.artist)"
        } else {
            let song = songs[indexPath.row]
            cell.textLabel?.text = song.title ?? "Unknown Song"
            cell.textLabel?.text = "\(song.title ?? "Unknown Song") — \(song.artist ?? "Unknown Artist")"
            cell.imageView?.image = song.artwork?.image(at: CGSize(width: 48, height: 48))
        }
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearchingCatalog {
            let song = searchResults[indexPath.row]
            player.setQueue(with: [song.id])
            player.play()
        } else {
            let queueItems = Array(songs[indexPath.row...])
            let collection = MPMediaItemCollection(items: queueItems)
            player.setQueue(with: collection)
            player.play()
        }
        showNowPlaying()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !term.isEmpty else { return }
        searchBar.resignFirstResponder()
        searchCatalog(term)
    }

    private func searchCatalog(_ term: String) {
        guard let token = PulseConfiguration.appleMusicDeveloperToken, !token.contains("PASTE_") else {
            showMessage("Add your Apple Music developer token in PulseConfiguration.swift to enable catalog search.")
            return
        }
        var components = URLComponents(string: "https://api.music.apple.com/v1/catalog/us/search")!
        components.queryItems = [URLQueryItem(name: "term", value: term), URLQueryItem(name: "types", value: "songs"), URLQueryItem(name: "limit", value: "25")]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            if let error = error { DispatchQueue.main.async { self.showMessage(error.localizedDescription) }; return }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(AppleMusicSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = response.results.songs?.data.map { CatalogSong(id: $0.id, title: $0.attributes.name, artist: $0.attributes.artistName) } ?? []
                    self.isSearchingCatalog = true
                    self.tableView.reloadData()
                }
            } catch { DispatchQueue.main.async { self.showMessage("Could not read Apple Music results.") } }
        }.resume()
    }

    @objc private func showNowPlaying() {
        navigationController?.pushViewController(NowPlayingViewController(player: player), animated: true)
    }

    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Pulse Music", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

struct CatalogSong { let id: String; let title: String; let artist: String }

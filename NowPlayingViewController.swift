import UIKit
import MediaPlayer

final class NowPlayingViewController: UIViewController {
    private let player: MPMusicPlayerController
    private let artworkView = UIImageView()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private let progress = UIProgressView(progressViewStyle: .default)
    private var timer: Timer?

    init(player: MPMusicPlayerController) { self.player = player; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Now Playing"
        view.backgroundColor = .systemBackground
        buildUI()
        refresh()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }
    deinit { timer?.invalidate() }

    private func buildUI() {
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        artworkView.contentMode = .scaleAspectFill
        artworkView.clipsToBounds = true
        artworkView.layer.cornerRadius = 18
        artworkView.backgroundColor = UIColor(white: 0.92, alpha: 1)
        artworkView.layer.shadowColor = UIColor.black.cgColor
        artworkView.layer.shadowOpacity = 0.12
        artworkView.layer.shadowRadius = 18
        artworkView.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.addSubview(artworkView)

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        artistLabel.font = .systemFont(ofSize: 16, weight: .regular)
        artistLabel.textColor = .secondaryLabel
        artistLabel.textAlignment = .center
        progress.progressTintColor = .label
        progress.trackTintColor = .tertiarySystemFill

        let previous = controlButton("backward.end.fill", action: #selector(previous))
        playButton.setTitle("▶︎", for: .normal)
        playButton.tintColor = .label
        playButton.backgroundColor = UIColor(white: 0.94, alpha: 1)
        playButton.layer.cornerRadius = 34
        playButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        let next = controlButton("forward.end.fill", action: #selector(nextTrack))
        let controls = UIStackView(arrangedSubviews: [previous, playButton, next])
        controls.axis = .horizontal
        controls.alignment = .center
        controls.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [titleLabel, artistLabel, progress, controls])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 22
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            artworkView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            artworkView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.72),
            artworkView.heightAnchor.constraint(equalTo: artworkView.widthAnchor),
            stack.topAnchor.constraint(equalTo: artworkView.bottomAnchor, constant: 34),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            playButton.widthAnchor.constraint(equalToConstant: 68),
            playButton.heightAnchor.constraint(equalToConstant: 68),
            previous.widthAnchor.constraint(equalToConstant: 42),
            next.widthAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func controlButton(_ symbol: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(symbol == "backward.end.fill" ? "⏮" : "⏭", for: .normal)
        button.tintColor = .label
        button.titleLabel?.font = .systemFont(ofSize: 25)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func refresh() {
        let item = player.nowPlayingItem
        titleLabel.text = item?.title ?? "Nothing Playing"
        artistLabel.text = item?.artist ?? "Choose a song from your library"
        artworkView.image = item?.artwork?.image(at: CGSize(width: 600, height: 600))
        let duration = item?.playbackDuration ?? 0
        if duration > 0 { progress.progress = Float(player.currentPlaybackTime / duration) } else { progress.progress = 0 }
        playButton.setTitle(player.playbackState == .playing ? "Ⅱ" : "▶︎", for: .normal)
        if player.playbackState == .playing && artworkView.layer.animation(forKey: "spin") == nil {
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = Double.pi * 2
            rotation.duration = 24
            rotation.repeatCount = .infinity
            artworkView.layer.add(rotation, forKey: "spin")
        } else if player.playbackState != .playing { artworkView.layer.removeAnimation(forKey: "spin") }
    }

    @objc private func togglePlayback() { player.playbackState == .playing ? player.pause() : player.play(); refresh() }
    @objc private func nextTrack() { player.skipToNextItem(); refresh() }
    @objc private func previous() { player.skipToPreviousItem(); refresh() }
}

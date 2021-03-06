//
//  AlbumDetailTableViewController.swift
//  Albums
//
//  Created by Shawn Gee on 4/6/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class AlbumDetailTableViewController: UITableViewController {
    
    // MARK: - Public Properties
    
    var albumController: AlbumController?
    var album: Album? { didSet { updateViews() }}
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var genresTextField: UITextField!
    @IBOutlet weak var coverArtURLsTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        save()
    }
    
    // MARK: - Private
    
    private var tempSongs = [Song]() {
        didSet {
            saveButton.isEnabled = !tempSongs.isEmpty
        }
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        if let album = album {
            title = album.name
            nameTextField.text = album.name
            artistTextField.text = album.artist
            genresTextField.text = album.genres.joined(separator: ", ")
            coverArtURLsTextField.text = album.coverArtURLs.joined(separator: ", ")
            tempSongs = album.songs
        } else {
            title = "New Album"
        }
    }
    
    private func save() {
        guard let name = nameTextField.text, let artist = artistTextField.text,
            let genres = genresTextField.text, let coverArtURLs = coverArtURLsTextField.text,
            !tempSongs.isEmpty else { return }
        
        let genresArray = genres.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        let coverArtURLsArray = coverArtURLs.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        
        if let album = album {
            albumController?.update(album, artist: artist, coverArtURLs: coverArtURLsArray,
                                    genres: genresArray, name: name, songs: tempSongs)
        } else {
            albumController?.createAlbum(artist: artist, coverArtURLs: coverArtURLsArray,
                                         genres: genresArray, name: name, songs: tempSongs)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Songs"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempSongs.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? SongTableViewCell else {
            fatalError("Unable to cast cell as \(SongTableViewCell.self)")
        }
        
        cell.delegate = self
        
        if indexPath.row < tempSongs.count {
            cell.song = tempSongs[indexPath.row]
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < tempSongs.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tempSongs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Table View Delegate
    
    private let cellYPadding: CGFloat = 8.0
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == tempSongs.count {
            return 140
        } else {
            return 116
        }
    }
}

// MARK: - Song Table View Cell Delegate

extension AlbumDetailTableViewController: SongTableViewCellDelegate {
    func addSong(withTitle title: String, duration: String) {
        guard let albumController = albumController else { return }
        let song = albumController.createSong(title: title, duration: duration)
        
        tableView.performBatchUpdates({
            tempSongs.append(song)
            tableView.reloadRows(at: [IndexPath(row: tempSongs.count - 1, section: 0)], with: .automatic)
            tableView.insertRows(at: [IndexPath(row: tempSongs.count, section: 0)], with: .automatic)
        })
        
        let indexPath = IndexPath(row: tempSongs.count, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}

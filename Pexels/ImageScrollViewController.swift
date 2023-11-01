//
//  ImageScrollViewController.swift
//  Pexels
//
//  Created by Айбану Уатбаева on 20.10.2023.
//

import UIKit

class ImageScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let imageURL: String
    
    init(imageURL: String){
        self.imageURL = imageURL
        super.init(nibName: "ImageScrollViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        loadImage()
    }
    func loadImage(){
        guard let url = URL(string: imageURL) else {
            print("Couldn't create URL instance with image URL: \(imageURL)")
            return
        }
        self.activityIndicatorView.startAnimating()
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler(data:urlResponse:error:))
        dataTask.resume()
    }
    func completionHandler(data: Data?, urlResponse: URLResponse?, error: Error?){
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
        
        if let error = error {
            print("Image loading error:\(error.localizedDescription)")
        } else if let data = data {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}

extension ImageScrollViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

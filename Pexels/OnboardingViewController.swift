//
//  OnboardingViewController.swift
//  Pexels
//
//  Created by Айбану Уатбаева on 05.10.2023.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    static let KEY: String = "UserDidASeeOnboarding"

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pages: [OnboardingModel] = []{
        didSet{
            pageControl.numberOfPages = pages.count
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: OnboardingCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        generatePages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skipButton.layer.cornerRadius = skipButton.frame.height / 2
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        
        
    }
    
    func generatePages(){
        pages = [
            OnboardingModel(imageName: "onboarding1", title: "Access Anywhere", subtitle: "The video call feature can be accessed from anywhere in your house to help you."),
            OnboardingModel(imageName: "onboarding2", title: "Don’t Feel Alone", subtitle: "Nobody likes to be alone and the built-in group video call feature helps you connect."),
            OnboardingModel(imageName: "onboarding3", title: "Happiness", subtitle: "While working the app reminds you to smile, laugh, walk and talk with those who matters.")
        ]
    }

    @IBAction func skipButtonClicked(_ sender: UIButton) {
        start()
    }
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        if pageControl.currentPage == pageControl.numberOfPages - 1 {
            start()
        } else {
            pageControl.currentPage += 1
            collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
//            let x: CGFloat = collectionView.frame.width * CGFloat(pageControl.currentPage)
//            collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            
            handlePageChanges()
            
        }
    }
    
    func start(){
        UserDefaults.standard.set(true, forKey: OnboardingViewController.KEY)
        
        let mainVC = MainViewController()
        let navC = UINavigationController(rootViewController: mainVC)
        view.window?.rootViewController = navC
        view.window?.makeKeyAndVisible()
    }
    
    func handlePageChanges(){
        if pageControl.currentPage == pageControl.numberOfPages - 1 {
            
            print("Last page")
            
            skipButton.isHidden = true
            nextButton.setTitle("Начать", for: .normal)
        } else {
            skipButton.isHidden = false
            nextButton.setTitle("Дальше", for: .normal)
        }
    }

}

extension OnboardingViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        
        let onboardingModel = pages[indexPath.item]
        cell.setup(onboardingModel: onboardingModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating at offset x: \(scrollView.contentOffset.x)")
        print("scrollView.frame.width : \(scrollView.frame.width)")

        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        print("pageControl.currentPage : \(pageControl.currentPage)")
        handlePageChanges()
    }
}

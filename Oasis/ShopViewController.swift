//
//  ShopViewController.swift
//  Oasis
//  View Controller for the Shop tab of the Oasis App.
//  CPSC 315-01 Fall 2020
//  Final Project
//  Sources: https://theswiftdev.com/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/
// https://www.journaldev.com/10678/ios-uicollectionview-example-tutorial
//
//  Created by Greeley Lindberg and William Parlan on 12/14/20.
//  Copyright © 2020 Lindberg Parlan. All rights reserved.
//

import UIKit
import CoreData

class ShopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // local variables
    var forSale: [ShopItem] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // outlets
    @IBOutlet var shopCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        populateForSale()
    }
    
    // Used to resize shop cells dynamically
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let flowLayout = self.shopCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: (self.shopCollection.bounds.width / 2) - 12, height: self.shopCollection.bounds.height / 3)
        }
    }
    
    // MARK: - Shop Helper Functions
    
    /**
     Populates the forSale array with initialized ShopItems.
     */
    func populateForSale() {
        // initialize heart plant
        let heartplant = ShopItem(plantName: "Heart Plant", imageName: "heart-plant", phase1WaterNeeded: 24, phase2WaterNeeded: 48, phase3WaterNeeded: 96)
        forSale.append(heartplant)
        
        // initialize rose
        let rose = ShopItem(plantName: "Roses", imageName: "rose", phase1WaterNeeded: 24, phase2WaterNeeded: 64, phase3WaterNeeded: 128)
        forSale.append(rose)
        
        // initialize cactus
        let cactus = ShopItem(plantName: "Cactus", imageName: "cactus", phase1WaterNeeded: 32, phase2WaterNeeded: 80, phase3WaterNeeded: 160)
        forSale.append(cactus)
        
        // initialize sunflower
        let sunflower = ShopItem(plantName: "Sunflower", imageName: "sunflower", phase1WaterNeeded: 32, phase2WaterNeeded: 64, phase3WaterNeeded: 96)
        forSale.append(sunflower)
        
        // initialize coming soon
        let comingSoon = ShopItem(plantName: "Coming Soon", imageName: "question-mark", phase1WaterNeeded: 0, phase2WaterNeeded: 0, phase3WaterNeeded: 0)
        forSale.append(comingSoon)
    }
    
    /**
     Replaces the current, fully-grown plant with the new plant selected from the shop.
     - parameter plant: The selected ShopItem that will replace the current plant.
     */
    func replaceOldPlant(with plant: ShopItem) {
        let request: NSFetchRequest<Plant> = Plant.fetchRequest()
        request.predicate = NSPredicate(format: "isCurrent == true")
        do {
            let oldPlant = try context.fetch(request)[0]
            let newPlant = Plant(context: context)
            oldPlant.isCurrent = false
            newPlant.isCurrent = true
            newPlant.waterLevel = 0
            newPlant.phase = 0
            newPlant.datePlanted = Date()
            newPlant.plantName = ""
            newPlant.imageName = plant.imageName
            newPlant.phase1WaterNeeded = Int32(plant.phase1WaterNeeded)
            newPlant.phase2WaterNeeded = Int32(plant.phase2WaterNeeded)
            newPlant.phase3WaterNeeded = Int32(plant.phase3WaterNeeded)
            performSegue(withIdentifier: "unwindToPlant", sender: nil)
        }
        catch {
            print("Error loading plant \(error)")
        }
    }
    
    /**
     Saves the context to CoreData.
     */
    func savePlant() {
        do {
            try context.save()
        }
        catch {
            print("Error saving plant \(error)")
        }
    }
    
    
    // MARK: - Collection View Functions
    
    // returns number of sections in collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // returns number of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forSale.count
    }
    
    // updates the cell with its respective ShopItem data.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let plant = forSale[index]
        
        let cell = shopCollection.dequeueReusableCell(withReuseIdentifier: "ShopCell", for: indexPath) as! ShopCell
        
        cell.plantNameLabel.text = plant.plantName
        if index < forSale.count - 1 {
            cell.plantImageView.image = UIImage(named: "\(plant.imageName)-phase-3")
        }
        else {
            cell.plantImageView.image = UIImage(named: "question-mark")
        }
        return cell
    }
    
    // Assigns spacing of rows and columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 8;
    }
    
    // Assigns spacing of the items in rows and columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3;
    }
    
    // Handles selection of a cell from the collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // user cannot select the "coming soon" cell
        if indexPath.row == forSale.count - 1 {
            return
        }
        let selectedPlant = forSale[indexPath.row]
        
        let request: NSFetchRequest<Plant> = Plant.fetchRequest()
        request.predicate = NSPredicate(format: "isCurrent == true")
        do {
            let currentPlant = try context.fetch(request)[0]
            if currentPlant.phase != 3 {
                alertInvalid()
            }
            else {
                verifyChoice(plant: selectedPlant)
            }
        }
        catch {
            print("Error loading plant \(error)")
        }
        
    }
    
    
    // MARK: - Alerts
    
    /**
     Asks the user to verify their choice of ShopItem.
     - parameter plant: The ShopItem the user selected.
     */
    func verifyChoice(plant: ShopItem) {
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you want to grow a \(plant.plantName.lowercased())?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            print("User pressed okay")
            self.replaceOldPlant(with: plant)
        }))
        alertController.addAction(UIAlertAction(title: "Choose another", style: .cancel, handler: { (action) -> Void in
            print("User pressed cancel")
        }))
        present(alertController, animated: true, completion: { () -> Void in
            print ("Alert presented")
        })
    }
    
    /**
     Alerts the user that they cannot buy another plant until they are done growing the current one.
     */
    func alertInvalid() {
        let alertController = UIAlertController(title: "Keep growing!", message: "You cannot get a new plant until you are done growing the current one.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
            print("User pressed okay")
        }))
        present(alertController, animated: true, completion: { () -> Void in
            print ("Alert presented")
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

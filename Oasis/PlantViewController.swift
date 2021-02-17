//
//  PlantViewController.swift
//  Oasis
//  View Controller for the Plant tab of the Oasis App.
//  CPSC 315-01 Fall 2020
//  Final Project
//  Sources: http://jtdz-solenoids.com/stackoverflow_/questions/15864364/viewdidappear-is-not-called-when-opening-app-from-background
//
//  Created by Greeley Lindberg and William Parlan on 12/1/20.
//  Copyright © 2020 Lindberg Parlan. All rights reserved.
//

import UIKit
import CoreData


class PlantViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - Local Variables
    var plant: Plant? = nil
    var isDead: Bool = false
    let dateFormatter = DateFormatter()
    var dailyWater = 0
    var today = ""
    let defaults = UserDefaults.standard
    var hasPlant = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let options = ["Cup (8 oz)", "Small water bottle (16 oz)", "Medium water bottle (24 oz)", "Large water bottle (32 oz)"]

    
    // MARK: - IBOutlets
    @IBOutlet var waterImage: UIImageView!
    @IBOutlet var popupView: UIView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var plantNameTextField: UITextField!
    @IBOutlet var plantImageView: UIImageView!

    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listens for when the view enters the foreground and reloads the plants when signaled
        NotificationCenter.default.addObserver(self, selector: #selector(loadPlant), name: UIApplication.willEnterForegroundNotification, object: nil)

        // Do any additional setup after loading the view.
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
        
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        
        // picker set up
        popupView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // check if first launch
        hasPlant = UserDefaults.standard.bool(forKey: "hasPlant")
        if !hasPlant {
            hasPlant = true
            UserDefaults.standard.setValue(true, forKey: "hasPlant")
            UserDefaults.standard.setValue(dateFormatter.string(from: Date()), forKey: "today")
            today = UserDefaults.standard.string(forKey: "today")!
            initPlant()
            savePlant()
        }
        else {
            loadPlant()
        }
        
        // load user defaults
        today = UserDefaults.standard.string(forKey: "today")!
        dailyWater = UserDefaults.standard.integer(forKey: "dailyWater")
    }
    
    // Loads the plants when the view appears
    override func viewDidAppear(_ animated: Bool) {
        loadPlant()
    }
    
    // Saves the context when the view disappears
    override func viewDidDisappear(_ animated: Bool) {
        savePlant()
    }
    
    // removes the forground observer when the view is destroyed
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Initializes the user's very first plant
     */
    func initPlant() {
        plant = Plant(context: context)
        plant!.phase = 0
        plant!.imageName = "heart-plant"
        plant!.phase1WaterNeeded = 8
        plant!.phase2WaterNeeded = 30
        plant!.phase3WaterNeeded = 50
        plant!.datePlanted = Date()
        plant!.isCurrent = true
        if let plantName = plantNameTextField.text {
            plant!.plantName = plantName
        }
    }
    
    /**
     Loads plants from CoreData.
     */
    @objc func loadPlant() {
        let request: NSFetchRequest<Plant> = Plant.fetchRequest()
        request.predicate = NSPredicate(format: "isCurrent == true")
        do {
            plant = try context.fetch(request)[0]
            plantNameTextField.text = plant!.plantName
            if let unwrappedDateLastWatered = plant!.dateLastWatered {
                if Date().timeIntervalSince(unwrappedDateLastWatered) > (48*60*60) && plant!.phase != 3 && plant!.phase != 0 { // interval is equal to two days
                    isDead = true;
                    plantImageView.image = UIImage(named: "\(plant!.imageName!)-phase-\(plant!.phase)-dead")
                    if ((plant!.phase == 1 && plant!.waterLevel > plant!.phase1WaterNeeded) || (plant!.phase == 2 && plant!.waterLevel > plant!.phase2WaterNeeded)) {
                        plant!.waterLevel = plant!.waterLevel - 16
                    }
                    alertDead()
                }
                else {
                    plantImageView.image = UIImage(named: "\(plant!.imageName!)-phase-\(plant!.phase)")
                }
            }
            else {
                plantImageView.image = UIImage(named: "\(plant!.imageName!)-phase-0")
            }
        }
        catch {
            print("No plant to load \(error)")
        }
    }
    
    /**
     Saves the context to CoreData
     */
    func savePlant() {
        do {
            try context.save()
        }
        catch {
            print("Error saving plant \(error)")
        }
    }
    
    /**
     Handles events when the water button is pressed.
     - parameter sender: The water button
     */
    @IBAction func waterButtonPressed(_ sender: UIButton) {
        if plant!.phase == 3 {
            let alertController = UIAlertController(title: "Time for a new plant!", message: "Your plant is fully grown. Go to the shop to buy a new  plant.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
                print("User pressed okay")
            }))
            present(alertController, animated: true, completion: { () -> Void in
                print ("Alert presented")
            })
            return
        }
        popupView.isHidden = false
        plant!.dateLastWatered = Date()
        savePlant()
    }
    
    /**
     Animates a watering can watering the plant.
     */
    func animateWater() {
        let frame1: UIImage! = UIImage(named: "water-frame-1")
        let frame2: UIImage! = UIImage(named: "water-frame-2")
        let frame3: UIImage! = UIImage(named: "water-frame-3")
        let frames: [UIImage] = [frame1, frame2, frame3]
        let animation: UIImage! = UIImage.animatedImage(with: frames, duration: 1.0)
        waterImage.image = animation
        let _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {(timer) in
            self.waterImage.image = nil
            self.updateGrowth()
        })
    }
    
    /**
     Updates the growth of the plant. If dead, the plant will come back but will not move up in phases.
     */
    func updateGrowth() {
        if isDead {
            plantImageView.image = UIImage(named: "\(plant!.imageName!)-phase-\(plant!.phase)")
            isDead = false
            return      // dead plant should not be able to grow to next phase
        }
        
        if (plant!.phase == 0 && plant!.waterLevel > plant!.phase1WaterNeeded) || (plant!.phase == 1 && plant!.waterLevel > plant!.phase2WaterNeeded) || (plant!.phase == 2 && plant!.waterLevel > plant!.phase3WaterNeeded) {
            plant!.phase += 1
            plantImageView.image = UIImage(named: "\(plant!.imageName!)-phase-\(plant!.phase)")
            if (plant!.phase == 3) {
                plant!.dateCompleted = Date()
                alertFullyGrown()
            }
        }
    }
    
    // MARK: - Alerts
    
    /**
     Alerts the user that their plant is fully grown.
     */
    func alertFullyGrown() {
        let alertController = UIAlertController(title: "Congratulations!", message: "Your plant is fully grown. Go to the shop to buy a new  plant.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
            print("User pressed okay")
        }))
        present(alertController, animated: true, completion: { () -> Void in
            print ("Alert presented")
        })
    }
    
    /**
     Alerts the user that theri plant has died.
     */
    func alertDead() {
        let alertController = UIAlertController(title: "Uh oh!", message: "Your plant is wilting. Give it a drink of water to revive it. It's important to stay hydrated and healthy.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
            print("User pressed okay")
        }))
        present(alertController, animated: true, completion: { () -> Void in
            print ("Alert presented")
        })
    }
    
    
    // MARK: - Picker View
    
    // returns the number of components in the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the number of rows in a component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    // returns the title for a row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    /**
     Handles watering actions afte the user presses done on the picker view. Plant data is incremented according to the selected option, data is updated for the calendar, and the watering animation is called.
     - parameter sender: The done button
     */
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let choiceIndex = pickerView.selectedRow(inComponent: 0) + 1
        plant!.waterLevel += Int32(choiceIndex) * 8
        plant!.totalWater += Int32(choiceIndex) * 8
        
        // reset dailyWater to be 0 if it is a new day
        if today != dateFormatter.string(from: Date()) {
            UserDefaults.standard.setValue(dateFormatter.string(from: Date()), forKey: "today")
            today = dateFormatter.string(from: Date())
            dailyWater = 0
        }
        dailyWater += choiceIndex * 8
        UserDefaults.standard.setValue(dailyWater, forKey: "dailyWater")
        let data = [plant!.plantName:dailyWater]
        defaults.setValue(data, forKey: today)
        popupView.isHidden = true
        animateWater()
    }
    
    /**
     Hides the picker view.
     - parameter sender: The cancel button.
     */
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        popupView.isHidden = true
    }
    
    // MARK: - Text Field
    
    // resigns the text field when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        plant!.plantName = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Closes the keyboard and resigns the text field when the background is tapped.
     - parameter sender: The UITapGestureRecognizer that registers the user's tap.
     */
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        plant!.plantName = plantNameTextField.text
        plantNameTextField.resignFirstResponder()
    }
    
    // MARK: - Segue
    /**
     Segue unwinding to Plant View Controller. Used by Shop View Controller.
     - parameter segue: The segue performing the unwind.
     */
    @IBAction func unwindToPlant(segue: UIStoryboardSegue) {}
}

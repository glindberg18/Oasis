//
//  PlantViewController.swift
//  Oasis
//
//  Created by Greeley Lindberg on 12/1/20.
//

import UIKit
import CoreData

class PlantViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // userdefaults
    
    @IBOutlet var waterImage: UIImageView!
    @IBOutlet var popupView: UIView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var plantNameTextField: UITextField!
    @IBOutlet var plantImageView: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var plant: Plant? = nil {
        didSet {
            savePlant()
        }
    }
    
    
    let options = ["Cup (8 oz)", "Small water bottle (16 oz)", "Medium water bottle (22 oz)", "Large water bottle (32 oz)"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
        popupView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        loadPlant()
    }
    
    
    func initPlant() {
        plant = Plant(context: context)
        plant!.phase = 0
        plant!.imageName = "heart-plant"
        plant!.phase1WaterNeeded = 1
        plant!.phase2WaterNeeded = 3
        plant!.totalWaterNeeded = 4
        plant!.datePlanted = Date()
        plant!.isCurrent = true
        if let plantName = plantNameTextField.text {
            plant!.plantName = plantName
        }
    }
    
    func loadPlant() {
        let request: NSFetchRequest<Plant> = Plant.fetchRequest()
        request.predicate = NSPredicate(format: "isCurrent MATCHES true")
        do {
            plant = try context.fetch(request)[0]
            plantNameTextField.text = plant!.plantName
            plantImageView.image = UIImage(named: "\(plant!.imageName)-phase-\(plant!.phase)")
        }
        catch {
            print("Error loading plant \(error)")
        }
    }
    
    func savePlant() {
        do {
            try context.save()
        }
        catch {
            print("Error saving plant \(error)")
        }
    }
    
    @IBAction func waterButtonPressed(_ sender: UIButton) {
        popupView.isHidden = false
        switch plant!.phase {
        case 0:
            if plant!.waterLevel >= plant!.phase1WaterNeeded {
                plant!.phase += 1
                loadPlant()
            }
        case 1:
            if plant!.waterLevel >= plant!.phase2WaterNeeded {
                plant!.phase += 1
                loadPlant()
            }
        case 2:
            if plant!.waterLevel >= plant!.totalWaterNeeded{
                plant!.phase += 1
                loadPlant()
                alertFullyGrown()
            }
        default:
            break
        }
    }
    
    func animateWater() {
        let frame1: UIImage! = UIImage(named: "water-frame-1")
        let frame2: UIImage! = UIImage(named: "water-frame-2")
        let frame3: UIImage! = UIImage(named: "water-frame-3")
        let frames: [UIImage] = [frame1, frame2, frame3]
        let animation: UIImage! = UIImage.animatedImage(with: frames, duration: 1.0)
        waterImage.image = animation
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {(timer) in
            self.waterImage.image = nil
        })
    }
    
    func alertFullyGrown() {
        let alertController = UIAlertController(title: "Congratulations!", message: "Your plant is fully grown. Go to the shop to buy a new  plant.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
            print("User pressed okay")
        }))
        present(alertController, animated: true, completion: { () -> Void in
            print ("Alert presented")
        })
    }
    
    // MARK: - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let choiceIndex = pickerView.selectedRow(inComponent: 0) + 1
        plant!.waterLevel += Int32(choiceIndex)
        popupView.isHidden = true
        animateWater()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        popupView.isHidden = true
    }
    
    // MARK: - Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Closes the keyboard and resigns the text field when the background is tapped.
     - parameter sender: The UITapGestureRecognizer that registers the user's tap.
     */
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        plantNameTextField.resignFirstResponder()
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

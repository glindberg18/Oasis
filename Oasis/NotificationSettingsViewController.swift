//
//  NotificationSettingsViewController.swift
//  Oasis
//
//  Created by Parlan, William C on 12/1/20.
//

import UIKit

class NotificationSettingsViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Local Variables
    var hour: Int? = nil
    var minute: Int? = nil
    var morning: Date? = nil
    var afternoon: Date? = nil
    var evening: Date? = nil
    var night: Date? = nil
    
    // MARK: - IBOutlets
    // Switch outlets
    @IBOutlet weak var disableAllSwitch: UISwitch!
    @IBOutlet weak var intervalSwitch: UISwitch!
    @IBOutlet weak var morningAlarm: UISwitch!
    @IBOutlet weak var afternoonAlarm: UISwitch!
    @IBOutlet weak var eveningAlarm: UISwitch!
    @IBOutlet weak var nightAlarm: UISwitch!
    // text field outlets
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    // date picker outlets
    @IBOutlet weak var morningDatePicker: UIDatePicker!
    @IBOutlet weak var afternoonDatePicker: UIDatePicker!
    @IBOutlet weak var eveningDatePicker: UIDatePicker!
    @IBOutlet weak var nightDatePicker: UIDatePicker!
    
    // MARK: - IBActions
    
    
    // MARK: - Switch Actions
    @IBAction func disableAllToggled(_ sender: UISwitch) {
        if sender.isOn{
            enableAll()
        }
        else{
            disableAll()
        }
    }
    @IBAction func intervalToggled(_ sender: UISwitch) {
        if (sender.isOn){
            disableAllSwitch.setOn(true, animated: true)
            hourTextField.isEnabled = true
            minuteTextField.isEnabled = true
            if let hourText = hourTextField.text{
                hour = Int(hourText)
            }
            if let minuteText = minuteTextField.text{
                minute = Int(minuteText)
                print(minute)
            }

        }
        else{
            hourTextField.isEnabled = false
            minuteTextField.isEnabled = false
            hour = nil
            minute = nil
        }
    }
    
    @IBAction func morningToggled(_ sender: UISwitch) {
        if (sender.isOn){
            disableAllSwitch.setOn(true, animated: true)
            morningDatePicker.isEnabled = true
            morning = morningDatePicker.date
        }
        else{
            morningDatePicker.isEnabled = false
            morning = nil
        }
    }
    
    @IBAction func afternoonToggled(_ sender: UISwitch) {
        if (sender.isOn){
            disableAllSwitch.setOn(true, animated: true)
            afternoonDatePicker.isEnabled = true
            afternoon = afternoonDatePicker.date
        }
        else{
            afternoonDatePicker.isEnabled = false
            afternoon = nil
        }
    }
    
    @IBAction func eveningToggled(_ sender: UISwitch) {
        if (sender.isOn){
            disableAllSwitch.setOn(true, animated: true)
            eveningDatePicker.isEnabled = true
            evening = eveningDatePicker.date
        }
        else{
            eveningDatePicker.isEnabled = false
            evening = nil
        }
    }
    
    @IBAction func nightToggled(_ sender: UISwitch) {
        if (sender.isOn){
            disableAllSwitch.setOn(true, animated: true)
            nightDatePicker.isEnabled = true
            night = nightDatePicker.date
        }
        else{
            nightDatePicker.isEnabled = false
            night = nil
        }
    }
    // MARK: - Text Field Actions
    @IBAction func hourTextFieldChanged(_ sender: UITextField) {
        if let hourText = sender.text{
            hour = Int(hourText)
        }
    }
    @IBAction func minuteTextFieldChanged(_ sender: UITextField) {
        if let minuteText = sender.text{
            minute = Int(minuteText)
        }
    }
    // date picker actions
    @IBAction func morningDatePickerChanged(_ sender: UIDatePicker) {
        morning = sender.date
    }
    @IBAction func afternoonDatePickerChanged(_ sender: UIDatePicker) {
        afternoon = sender.date
    }
    @IBAction func eveningDatePickerChanged(_ sender: UIDatePicker) {
        evening = sender.date
    }
    @IBAction func nightDatePickerChanged(_ sender: UIDatePicker) {
        night = sender.date
        print(night)
    }
    //MARK: - Tap Gesture
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer){
        hourTextField.resignFirstResponder()
        minuteTextField.resignFirstResponder()
        morningDatePicker.resignFirstResponder()
        afternoonDatePicker.resignFirstResponder()
        eveningDatePicker.resignFirstResponder()
        nightDatePicker.resignFirstResponder()
        
    }
    
    
    // MARK: - Helper Functions
    func disableAll(){
        // switches
        intervalSwitch.setOn(false, animated: true)
        morningAlarm.setOn(false, animated: true)
        afternoonAlarm.setOn(false, animated: true)
        eveningAlarm.setOn(false, animated: true)
        nightAlarm.setOn(false, animated: true)
        
        // disable text fields
        hourTextField.isEnabled = false
        minuteTextField.isEnabled = false
        
        // disable date pickers
        morningDatePicker.isEnabled = false
        afternoonDatePicker.isEnabled = false
        eveningDatePicker.isEnabled = false
        nightDatePicker.isEnabled = false
        
    }
    func enableAll(){
        intervalSwitch.setOn(true, animated: true)
        morningAlarm.setOn(true, animated: true)
        afternoonAlarm.setOn(true, animated: true)
        eveningAlarm.setOn(true, animated: true)
        nightAlarm.setOn(true, animated: true)
        
        // disable text fields
        hourTextField.isEnabled = true
        minuteTextField.isEnabled = true
        
        // disable date pickers
        morningDatePicker.isEnabled = true
        afternoonDatePicker.isEnabled = true
        eveningDatePicker.isEnabled = true
        nightDatePicker.isEnabled = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

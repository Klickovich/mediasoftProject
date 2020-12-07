//
//  ViewController.swift
//  klickmoney
//
//  Created by klick on 04.12.2020.
//

import UIKit

class ViewController: UIViewController {
    
    var keys: [String] = []
    var values: [Double] = []
    var ruble: Double?
    //оутлеты активно соединяют view controller и main.storyboard//
    @IBOutlet weak var RuTF: UITextField!
    @IBOutlet weak var UsTF: UITextField!
    //delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        RuTF.delegate = self
        UsTF.delegate = self
        dataRequest()
        notificationKeyboard()
    }
    
    @IBAction func convertUSDToRUB(_ sender: Any) {
        if let text = UsTF.text, let rub = ruble, !text.isEmpty {
            RuTF.text = String(Double(text)! * rub)
        }
    }
    
    //проверка HTTPS на валидность адреса, с условием else - если адрес больной то происходит выход {return}//
    
    func dataRequest() {
        guard let url = URL (string: "https://open.exchangerate-api.com/v6/latest") else { return }
        
        // сессия shared для валидного адреса, метод-dataTasc извлекает содержимое по указанному адресу, guard проверяем содержимое data, если данные отсутствуют то происходит выход {return}//
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data
            else {return}
            do {
    //JSONDecoder раскодирует полученные данные
                let json = try JSONDecoder().decode(Rates.self, from: data)
                self.keys.append(contentsOf: json.rates.keys)
                self.values.append(contentsOf: json.rates.values)
                self.ruble = json.rates["RUB"]
                print(json)
            }
            catch {
                print(error)
            }
        }.resume()
    }
    //вывод клавиатуры
    func notificationKeyboard () {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (nc) in
                self.view.frame.origin.y = -50
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (nc) in
                self.view.frame.origin.y = 0.0
            }
        }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.UsTF.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.UsTF.resignFirstResponder()
        self.RuTF.resignFirstResponder()
        return true
    }
}

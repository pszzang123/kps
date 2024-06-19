////
////  OpenAIViewController.swift
////  kps
////
////  Created by mac035 on 6/13/24.
////
//
//
//import UIKit
//import Alamofire
//import Foundation
//
//
////struct ChatCompletion: Codable {
////    struct Choice: Codable {
////        let message: Message
////    }
////    
////    struct Message: Codable {
////        let role: String
////        let content: String
////    }
////    
////    let choices: [Choice]
////}
//
//class OpenAIViewController: UIViewController {
//    
//    let apiKey = ""
//    
////    @IBOutlet weak var userInputTextField: UITextField!
////    @IBOutlet weak var resultTextView: UITextView!
//    
//    
//    @IBAction func generateStoryButton(_ sender: UIButton) {
//        guard let userInput = userInputTextField.text, !userInput.isEmpty else {
//            print("User input is empty")
//            return
//        }
//        
//        let prompt = "\(userInput)를 주제로 동화 이야기 만들어줘."
//        callOpenAIAPI(with: prompt)
//    }
//    
//    func callOpenAIAPI(with prompt: String, retryCount: Int = 0) {
//            let url = "https://api.openai.com/v1/chat/completions"
//            let headers: HTTPHeaders = [
//                "Authorization" : "Bearer \(apiKey)",
//                "Content-Type" : "application/json"
//            ]
//            let parameters: [String: Any] = [
//                "model": "gpt-3.5-turbo", // Chat model name
//                "messages": [
//                    ["role": "user", "content": prompt]
//                ],
//                "max_tokens": 1500,
//                "temperature": 0.7
//            ]
//            
//            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//                .validate(statusCode: 200..<300)
//                .responseDecodable(of: ChatCompletion.self) { response in
//                    switch response.result {
//                    case .success(let openAIResponse):
//                        if let firstChoice = openAIResponse.choices.first {
//                            DispatchQueue.main.async {
//                                self.resultTextView.text = firstChoice.message.content
//                            }
//                        }
//                    case .failure(let error):
//                        if let afError = error.asAFError, afError.responseCode == 429, retryCount < 3 {
//                            // 재시도 로직: 429 오류 발생 시 최대 3번까지 재시도
//                            let retryDelay = Double(retryCount + 1) * 2.0 // 지연 시간 증가
//                            DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
//                                self.callOpenAIAPI(with: prompt, retryCount: retryCount + 1)
//                            }
//                        } else {
//                            print(error.localizedDescription)
//                        }
//                    }
//                }
//        }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//}

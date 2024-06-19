//
//  MainViewController.swift
//  kps
//
//  Created by mac035 on 6/10/24.
//

import UIKit
import Lottie
import Combine
import Alamofire
import Foundation
import Firebase

struct ChatCompletion: Codable {
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    let choices: [Choice]
} // OPEN AI BODY

class MainViewController: UIViewController {
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    
    var subscriptions = Set<AnyCancellable>()
    var kakaoLoginLogoutButton : UIButton! // 로그인 로그아웃 처리 버튼
    var receivedSubject : String = "이야기 주제를 입력해주세요."   // 저장되어있던 이야기 주제
    var receivedStory: String = "이야기가 만들어지는 자리입니다." // 저장되어있던 이야기 내용
    
    let apiKey = "sk-proj-rhigC6bWiQOm4ENewseIT3BlbkFJmevJXXkAVERWjD6yWpk8" // OPEN AI KEY

    
    
    lazy var alertController = { (_ message: String) -> UIAlertController in
        let alert = UIAlertController(title: "!", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default){
            _ in print("확인 tapped")
        }
        let cancel = UIAlertAction(title: "취소", style: .default){
            _ in print("취소 tapped")
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        return alert
        
    } // 로그인 하지 않고 저장목록 클릭 시 알림
    lazy var generateStoryButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("이야기 생성하기", for: .normal)
        btn.configuration = .filled()
        btn.titleLabel?.textColor = .white
        btn.backgroundColor = UIColor.darkGray
        btn.addTarget(self, action: #selector(generateStory), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }() // 이야기 생성 버튼
    lazy var kakaoButton = { (_ title: String, _ action: Selector) -> UIButton in
            let btn = UIButton()
            btn.setTitle(title, for: .normal)
            btn.configuration = .filled()
            btn.titleLabel?.textColor = .white
            btn.addTarget(self, action: action, for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
    } // 카카오 버튼
    lazy var savedListButton : UIButton = {
        let btn = UIButton()
        //btn.setTitle("savedList", for: .normal)
        if let image = UIImage(systemName: "tray.and.arrow.down.fill"){
            btn.setImage(image, for: .normal)
            //btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        }
        btn.addTarget(self, action: #selector(navigatePage), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }() // 저장된 이야기 목록 버튼
    lazy var saveStoryButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("이야기 저장하기", for: .normal)
        btn.configuration = .filled()
        btn.titleLabel?.textColor = .white
        btn.addTarget(self, action: #selector(saveStory), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }() // 이야기 생성 버튼
    lazy var stackView : UIStackView = {
        let stack = UIStackView()
        stack.spacing = 16
        stack.axis = .vertical
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }() // 스택 뷰
    
    lazy var kakaoAuthVM: KakaoAuthVM = { KakaoAuthVM()}() //kakao 로그인 api

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingOutlet() // textField, textView 설정

        view.backgroundColor = .black
        kakaoLoginLogoutButton = self.kakaoButton("로그인", #selector(self.loginBtnClicked))
        view.addSubview(kakaoLoginLogoutButton)
        view.addSubview(savedListButton)
        stackView.addArrangedSubview(userInputTextField)
        stackView.addArrangedSubview(generateStoryButton)
        stackView.addArrangedSubview(resultTextView)
        stackView.addArrangedSubview(saveStoryButton)
        
        // 로그인 로그아웃 버튼 위치 설정
        kakaoLoginLogoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        kakaoLoginLogoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50).isActive = true

        // 저장 버튼 위치 설정
        savedListButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        savedListButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50).isActive = true

        
        let twoThirdsHeight = view.bounds.height * 2 / 3

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            // Center horizontally
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                // Top constraint: 2/3 from the top of the view
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: twoThirdsHeight / 3),

            // Limiting constraints to keep stackView within bounds
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
            
        setBindings() // 카카오 데이터 바인딩
    } //viewDidLoad()
    
    func settingOutlet() {
        userInputTextField.placeholder = receivedSubject
        userInputTextField.textColor = .black
        userInputTextField.textAlignment = .center
        userInputTextField.borderStyle = .roundedRect
        userInputTextField.translatesAutoresizingMaskIntoConstraints = false
        
        resultTextView.textColor = .white
        resultTextView.text = receivedStory
        resultTextView.textAlignment = .center
        resultTextView.backgroundColor = UIColor.black
        resultTextView.layer.borderWidth = 1.0
        resultTextView.layer.borderColor = UIColor.white.cgColor
        resultTextView.layer.cornerRadius = 10.0
        resultTextView.layer.masksToBounds = true
        resultTextView.isScrollEnabled = true
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        
                // Explicit height constraint
        resultTextView.heightAnchor.constraint(equalToConstant: view.bounds.height/2).isActive = true
        
                // Lower content compression resistance priority
        resultTextView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
    } // textField, textView 설정 => Outlet 설정해야해서.
    @objc func loginBtnClicked(){
        print("loginBtnClicked() called")
        kakaoAuthVM.kakaoLogin()
    } // 로그인 버튼 클릭
    @objc func logoutBtnClicked(){
        print("logoutBtnClicked() called")
        kakaoAuthVM.kakaoLogout()
    } // 로그아웃 버튼 클릭
    @objc func navigatePage(){
        if kakaoAuthVM.currentUser == "" {
            present(alertController("로그인이 필요한 서비스"), animated: true, completion: nil)
        }
        else{
            self.performSegue(withIdentifier: "navigateToSavedList", sender: self)
        }
    } // 저장 목록으로 화면 이동
    @objc func generateStory() {
        guard let userInput = self.userInputTextField.text, !userInput.isEmpty else {
            print("User input is empty")
            return
        }
        print("User Input Text: \(userInput)")
        
        let prompt = "\(userInput)를 주제로 동화 이야기 만들어줘."
        callOpenAIAPI(with: prompt)
        
    } //이야기 생성 action
    @objc func saveStory() {
        if kakaoAuthVM.currentUser == "" {
            present(alertController("로그인이 필요한 서비스"), animated: true, completion: nil)
        } // 로그아웃 상태
        else {
            if let userInput = userInputTextField.text, !userInput.isEmpty,
               let resultText = resultTextView.text, !resultText.isEmpty {
                
                let data: [String:Any] = [
                    "userId" : kakaoAuthVM.currentUser,
                    "subject" : userInput,
                    "story" : resultText
                ]
                
                Firestore.firestore().collection("stories").document().setData(data) {error in
                    if let error = error {
                        self.present(self.alertController("ERROR"), animated: true, completion: nil)
                    } // db 저장 error
                    else {
                        self.present(self.alertController("저장되었습니다."), animated: true, completion: nil)
                    } // db 저장 success
                }
                
                
            } // 입력값 있는 경우
            else {
                print(userInputTextField.text as Any)
                print(resultTextView.text as Any)
                present(alertController("데이터가 없습니다."), animated: true, completion: nil)
            } // 입력값이 비어있는 경우

        } // 로그인 상태
        
    } // 이야기 저장 버튼

}

extension MainViewController {
    fileprivate func setBindings() {
            kakaoAuthVM.loginStatusInfo
                .receive(on: DispatchQueue.main)
                .sink { [weak self] loginStatus in
                    guard let self = self else { return }
                    if self.kakaoAuthVM.isLoggedIn {
                        self.kakaoLoginLogoutButton.setTitle("로그아웃", for: .normal)
                        self.kakaoLoginLogoutButton.removeTarget(self, action: #selector(loginBtnClicked), for: .touchUpInside)
                        self.kakaoLoginLogoutButton.addTarget(self, action: #selector(logoutBtnClicked), for: .touchUpInside)
                    } //로그인 된 경우에 대한 처리
                    else {
                        self.kakaoLoginLogoutButton.setTitle("로그인", for: .normal)
                        self.kakaoLoginLogoutButton.removeTarget(self, action: #selector(logoutBtnClicked), for: .touchUpInside)
                        self.kakaoLoginLogoutButton.addTarget(self, action: #selector(loginBtnClicked), for: .touchUpInside)
                    } // 로그아웃 된 경우에 대한 처리
                }
                .store(in: &subscriptions)
        }
} //카카오 로그인 유무에 따른 처리
extension MainViewController {
    fileprivate func callOpenAIAPI(with prompt: String, retryCount: Int = 0) {
        let url = "https://api.openai.com/v1/chat/completions"
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer \(apiKey)",
            "Content-Type" : "application/json"
        ]
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo", // Chat model name
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1500,
            "temperature": 0.7
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ChatCompletion.self) { response in
                switch response.result {
                case .success(let openAIResponse):
                    if let firstChoice = openAIResponse.choices.first {
                        DispatchQueue.main.async {
                            self.resultTextView.text = firstChoice.message.content
                        }
                    }
                case .failure(let error):
                    if let afError = error.asAFError, afError.responseCode == 429, retryCount < 3 {
                        // 재시도 로직: 429 오류 발생 시 최대 3번까지 재시도
                        let retryDelay = Double(retryCount + 1) * 2.0 // 지연 시간 증가
                        DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
                            self.callOpenAIAPI(with: prompt, retryCount: retryCount + 1)
                        }
                    } else {
                        print(error.localizedDescription)
                    }
                }
            }
    }

} // open ai generate story
extension MainViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigateToSavedList" {
            // 목적지 뷰 컨트롤러 얻기
            if let destinationVC = segue.destination as? savedListViewController {
                // 데이터 전달
                destinationVC.currentUser = kakaoAuthVM.currentUser
            }
            
        }
    }
} // 현재 로그인 유저 전달

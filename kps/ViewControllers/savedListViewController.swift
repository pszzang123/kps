import UIKit
import Foundation
import FirebaseFirestore



// Story 구조체 정의
struct Story {
    var subject: String
    var story: String
} //firebase data 구조


class savedListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentUser: String?
    var selectedSubject: String?
    var selectedStory: String?

    
    @IBOutlet weak var tableView: UITableView!
    
    var stories: [Story] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "storyCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        // 배경색 설정 (옵션)
        view.backgroundColor = .black
        
        // TableView의 AutoresizingMask 설정 (옵션)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        print("현재 로그인 유저 : \(currentUser ?? "")")
        
        // Firebase Firestore에서 데이터 가져오기
        fetchStoriesFromFirestore()
    }
    func fetchStoriesFromFirestore() {
        guard let currentUser = currentUser else {
            print("Current user is nil.")
            return
        }
            
        let stories = Firestore.firestore().collection("stories")
            
        // currentUser와 동일한 문서들을 가져오기
        stories.whereField("userId", isEqualTo: currentUser).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching stories: \(error.localizedDescription)")
                return
            }
                
            guard let documents = querySnapshot?.documents else {
                print("No documents found.")
                return
            }
            
            self.stories.removeAll() // 기존 데이터 초기화
                
            for document in documents {
                let data = document.data()
                if let subject = data["subject"] as? String,
                    let story = data["story"] as? String {
                    let storyObject = Story(subject: subject, story: story)
                    self.stories.append(storyObject)
                }
            }
                
                // 테이블 뷰 리로드
                self.tableView.reloadData()
            }
        }
    
    // UITableViewDataSource 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectStoryTableViewCell", for: indexPath) as! subjectStoryTableViewCell
        
        let story = stories[indexPath.row]
        
        print("add subject: \(story.subject)")
        print("add story: \(story.story)")
        cell.subjectLabel.text = story.subject
        cell.storyLabel.text = story.story
        
        
        cell.subjectLabel.lineBreakMode = .byTruncatingTail // 생략 부호로 표시 설정
        cell.subjectLabel.numberOfLines = 1 // 텍스트가 한 줄로 제한됨 (필요에 따라 다르게 설정 가능)
        cell.storyLabel.lineBreakMode = .byTruncatingTail // 생략 부호로 표시 설정
        cell.storyLabel.numberOfLines = 1 // 텍스트가 한 줄로 제한됨 (필요에 따라 다르게 설정 가능)
        
        
        return cell
    } // table cell 추가

    
    // UITableViewDelegate 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = stories[indexPath.row]
        print("Selected subject: \(selectedList.subject)")
        print("Selected story: \(selectedList.story)")
        selectedSubject = selectedList.subject
        selectedStory = selectedList.story
        
        self.performSegue(withIdentifier: "backToMain", sender: self)
    } // 셀 클릭 시 화면 전환 및 데이터 전달
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMain" {
            // destination ViewController 가져오기 (여기서는 mainViewController)
            if let mainVC = segue.destination as? MainViewController {
                // 데이터 전달
                mainVC.receivedSubject = selectedSubject ?? "이야기 주제를 입력해주세요."
                mainVC.receivedStory = selectedStory ?? "이야기가 만들어지는 자리입니다."
            }
            segue.destination.modalPresentationStyle = .fullScreen
        }
    } // segue가 실행되기 전에 데이터를 준비하는 메서드
}

import UIKit
import MapKit

// MARK: - CustomPOIDetailViewController
/// POI 상세 정보를 팝오버 형태로 표시하는 뷰 컨트롤러
/// 팝오버 커스텀해둔 부분
class CustomPOIDetailViewController: UIViewController {

    let mapItem: MKMapItem
    
    // MARK: - 초기화
    
    /// mapItem을 받아 컨트롤러를 초기화하며 팝오버 스타일과 크기를 설정합니다.
    /// - Parameter mapItem: 선택된 POI의 MKMapItem 객체
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        super.init(nibName: nil, bundle: nil)
        // 뷰 컨트롤러를 팝오버로 표시
        self.modalPresentationStyle = .popover
        // 초기 preferredContentSize 설정
        self.preferredContentSize = CGSize(width: 300, height: 270)
    }
    
    /// 스토리보드/니브를 사용할 때 호출되지 않도록 처리
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 뷰 생명주기
    
    /// 뷰가 로드된 후 UI 구성 및 데이터 바인딩을 수행합니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        self.preferredContentSize = CGSize(width: 320, height: 270)
        
        // MARK: - 기본 정보 컨테이너
        
        let container1 = UIView()
        container1.backgroundColor = .white
        container1.layer.cornerRadius = 8
        container1.translatesAutoresizingMaskIntoConstraints = false
        
        // POI 이름 라벨 생성
        let nameLabel = UILabel()
        // incoming: mapItem.name, outgoing: 화면에 POI 이름 표시
        nameLabel.text = "\(mapItem.name ?? "Unknown")"
        nameLabel.font = .boldSystemFont(ofSize: 18)
        
        // 좌표 라벨 생성
        let coord = mapItem.placemark.coordinate
        let coordLabel = UILabel()
        // incoming: mapItem.placemark.coordinate, outgoing: 위도/경도 텍스트 표시
        coordLabel.text = "위도: \(coord.latitude), 경도: \(coord.longitude)"
        coordLabel.font = .systemFont(ofSize: 12)
        coordLabel.textColor = .secondaryLabel
        
        // 스택뷰에 라벨 추가
        let innerStack1 = UIStackView(arrangedSubviews: [nameLabel, coordLabel])
        innerStack1.axis = .vertical
        innerStack1.spacing = 4
        innerStack1.translatesAutoresizingMaskIntoConstraints = false
        container1.addSubview(innerStack1)
        
        // 제약조건 설정
        NSLayoutConstraint.activate([
            innerStack1.topAnchor.constraint(equalTo: container1.topAnchor, constant: 12),
            innerStack1.leadingAnchor.constraint(equalTo: container1.leadingAnchor, constant: 12),
            innerStack1.trailingAnchor.constraint(equalTo: container1.trailingAnchor, constant: -12),
            innerStack1.bottomAnchor.constraint(equalTo: container1.bottomAnchor, constant: -12)
        ])
        
        // MARK: - 세부 정보 헤더
        
        let detailHeader = UILabel()
        detailHeader.text = "세부사항"
        detailHeader.font = .boldSystemFont(ofSize: 16)
        detailHeader.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - 주소 및 전화 컨테이너
        
        let container2 = UIView()
        container2.backgroundColor = .white
        container2.layer.cornerRadius = 8
        container2.translatesAutoresizingMaskIntoConstraints = false
        
        let addressTitle = UILabel()
        addressTitle.text = "주소"
        addressTitle.font = .systemFont(ofSize: 13)
        addressTitle.textColor = .secondaryLabel
        
        let addressLabel = UILabel()
        // incoming: mapItem.placemark.title, outgoing: UILabel에 주소 표시
        addressLabel.text = mapItem.placemark.title ?? "정보 없음"
        addressLabel.font = .systemFont(ofSize: 12)
        addressLabel.numberOfLines = 2
        
        let phoneTitle = UILabel()
        phoneTitle.text = "전화"
        phoneTitle.font = .systemFont(ofSize: 13)
        phoneTitle.textColor = .secondaryLabel
        
        let phoneLabel = UILabel()
        // incoming: mapItem.phoneNumber, outgoing: UILabel에 전화번호 표시
        phoneLabel.text = mapItem.phoneNumber ?? "정보 없음"
        phoneLabel.font = .systemFont(ofSize: 12)
        
        let innerStack2 = UIStackView(arrangedSubviews: [addressTitle, addressLabel, phoneTitle, phoneLabel])
        innerStack2.axis = .vertical
        innerStack2.spacing = 4
        innerStack2.translatesAutoresizingMaskIntoConstraints = false
        container2.addSubview(innerStack2)
        
        NSLayoutConstraint.activate([
            innerStack2.topAnchor.constraint(equalTo: container2.topAnchor, constant: 12),
            innerStack2.leadingAnchor.constraint(equalTo: container2.leadingAnchor, constant: 12),
            innerStack2.trailingAnchor.constraint(equalTo: container2.trailingAnchor, constant: -12),
            innerStack2.bottomAnchor.constraint(equalTo: container2.bottomAnchor, constant: -12)
        ])
        
        // MARK: - 메인 스택뷰 구성
        
        let mainStack = UIStackView(arrangedSubviews: [container1, detailHeader, container2])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

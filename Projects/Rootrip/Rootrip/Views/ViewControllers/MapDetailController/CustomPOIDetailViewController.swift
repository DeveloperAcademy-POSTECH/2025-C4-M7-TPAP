import UIKit
import MapKit

class CustomPOIDetailViewController: UIViewController {
    let mapItem: MKMapItem

    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .popover
        self.preferredContentSize = CGSize(width: 300, height: 270)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        self.preferredContentSize = CGSize(width: 320, height: 270)

        let container1 = UIView()
        container1.backgroundColor = .white
        container1.layer.cornerRadius = 8
        container1.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = "\(mapItem.name ?? "Unknown")"
        nameLabel.font = .boldSystemFont(ofSize: 18)

        let coord = mapItem.placemark.coordinate
        let coordLabel = UILabel()
        coordLabel.text = "위도: \(coord.latitude), 경도: \(coord.longitude)"
        coordLabel.font = .systemFont(ofSize: 12)
        coordLabel.textColor = .secondaryLabel

        let innerStack1 = UIStackView(arrangedSubviews: [nameLabel, coordLabel])
        innerStack1.axis = .vertical
        innerStack1.spacing = 4
        innerStack1.translatesAutoresizingMaskIntoConstraints = false
        container1.addSubview(innerStack1)
        

        NSLayoutConstraint.activate([
            innerStack1.topAnchor.constraint(equalTo: container1.topAnchor, constant: 12),
            innerStack1.leadingAnchor.constraint(equalTo: container1.leadingAnchor, constant: 12),
            innerStack1.trailingAnchor.constraint(equalTo: container1.trailingAnchor, constant: -12),
            innerStack1.bottomAnchor.constraint(equalTo: container1.bottomAnchor, constant: -12)
        ])

        let detailHeader = UILabel()
        detailHeader.text = "세부사항"
        detailHeader.font = .boldSystemFont(ofSize: 16)
        detailHeader.translatesAutoresizingMaskIntoConstraints = false

        let container2 = UIView()
        container2.backgroundColor = .white
        container2.layer.cornerRadius = 8
        container2.translatesAutoresizingMaskIntoConstraints = false

        let addressTitle = UILabel()
        addressTitle.text = "주소"
        addressTitle.font = .systemFont(ofSize: 13)
        addressTitle.textColor = .secondaryLabel

        let addressLabel = UILabel()
        addressLabel.text = mapItem.placemark.title ?? "정보 없음"
        addressLabel.font = .systemFont(ofSize: 12)
        addressLabel.numberOfLines = 2

        let phoneTitle = UILabel()
        phoneTitle.text = "전화"
        phoneTitle.font = .systemFont(ofSize: 13)
        phoneTitle.textColor = .secondaryLabel

        let phoneLabel = UILabel()
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


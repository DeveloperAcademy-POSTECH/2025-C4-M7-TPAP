//
//  writeMapDetailView.swift
//  Rootrip
//
//  Created by POS on 7/28/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct writeMapDetailView: View {
    @State private var projectID: String = ""
    @State private var planID: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    
    @State private var statusMessage: String = ""
    
    private let repository: MapDetailRepositoryProtocol = MapDetailRepository()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("프로젝트 & 플랜 정보")) {
                    TextField("Project ID", text: $projectID)
                    TextField("Plan ID", text: $planID)
                }

                Section(header: Text("장소 정보")) {
                    TextField("위도 (latitude)", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("경도 (longitude)", text: $longitude)
                        .keyboardType(.decimalPad)
                }

                Button("MapDetail 추가하기") {
                    addMapDetail()
                }
                .disabled(!isFormValid)

                if !statusMessage.isEmpty {
                    Section {
                        Text(statusMessage)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("MapDetail 디버깅 입력")
        }
    }

    private var isFormValid: Bool {
        !projectID.isEmpty && !planID.isEmpty &&
        Double(latitude) != nil && Double(longitude) != nil
    }

    private func addMapDetail() {
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            statusMessage = "❗️위도/경도를 숫자로 입력하세요."
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let newDetail = MapDetail(
            id: nil,
            planID: planID,
            latitude: lat,
            longitude: lon
        )

        Task {
            do {
                try await repository.addMapDetail(projectID: projectID, planID: planID, detail: newDetail)
                statusMessage = "✅ MapDetail 추가 성공!"
            } catch {
                statusMessage = "❌ 에러: \(error.localizedDescription)"
            }
        }
    }
}

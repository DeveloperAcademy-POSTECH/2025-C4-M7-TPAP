//
//  writeMapDetailView.swift
//  Rootrip
//
//  Created by POS on 7/28/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct WriteMapDetailView: View {
    enum TargetType: String, CaseIterable, Identifiable {
        case plan = "플랜"
        case bookmark = "북마크"
        var id: String { rawValue }
    }

    @State private var projectID: String = ""
    @State private var containerID: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var selectedTarget: TargetType = .plan

    @State private var statusMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Picker("저장 대상", selection: $selectedTarget) {
                    ForEach(TargetType.allCases) { target in
                        Text(target.rawValue).tag(target)
                    }
                }
                .pickerStyle(.segmented)

                Section(header: Text("프로젝트 & 대상 ID")) {
                    TextField("Project ID", text: $projectID)
                    TextField("\(selectedTarget.rawValue) ID", text: $containerID)
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
        !projectID.isEmpty && !containerID.isEmpty &&
        Double(latitude) != nil && Double(longitude) != nil
    }

    private func addMapDetail() {
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            statusMessage = "❗️위도/경도를 숫자로 입력하세요."
            return
        }

        let newDetail = MapDetail(
            containerID: containerID,
            latitude: lat,
            longitude: lon
        )

        Task {
            do {
                let repo = MapDetailRepository()
                switch selectedTarget {
                case .plan:
                    try await repo.addMapDetailToPlan(projectID: projectID, planID: containerID, detail: newDetail)
                case .bookmark:
                    try await repo.addMapDetailToBook(projectID: projectID, bookmarkID: containerID, detail: newDetail)
                }
                statusMessage = "✅ MapDetail 추가 성공!"
            } catch {
                statusMessage = "❌ 에러: \(error.localizedDescription)"
            }
        }
    }
}

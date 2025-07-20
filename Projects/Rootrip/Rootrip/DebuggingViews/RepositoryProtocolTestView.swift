//
//  RepositoryProtocolTestView.swift
//  Rootrip
//
//  Created by POS on 7/20/25.
//
//  이 뷰는 조작기(버튼)만 제공합니다. 실제 데이터 변화는 firebase team space에서 Firestore확인
//  호출방법: RepositoryProtocolTestView(repository1: ProjectRepository(), repository2: PlanRepository(), repository3: BookmarkRepository())

import SwiftUI
import FirebaseFirestore

struct RepositoryProtocolTestView: View {
    @State private var title: String = ""
    @State private var tripType: TripType = .dayTrip
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var includeEndDate = false

    @State private var errorMessage: String?

    let repository1: ProjectRepository
    let repository2: PlanRepository
    let repository3: BookmarkRepository
    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("프로젝트 정보 입력")) {
                    TextField("제목", text: $title)

                    Picker("여행 타입", selection: $tripType) {
                        ForEach(TripType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }

                    DatePicker("시작일", selection: $startDate, displayedComponents: .date)

                    Toggle("종료일 포함", isOn: $includeEndDate)

                    if includeEndDate {
                        DatePicker("종료일", selection: Binding<Date>(
                            get: { endDate ?? startDate },
                            set: { endDate = $0 }
                        ), displayedComponents: .date)
                    }
                }

                Section(header: Text("테스트 액션")) {
                    Button("① 프로젝트 생성") {
                        Task {
                            do {
                                try await repository1.createProject(
                                    title: title.isEmpty ? nil : title,
                                    tripType: tripType,
                                    startDate: startDate,
                                    endDate: includeEndDate ? endDate : nil
                                ) { _ in }
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }

                    Button("② 랜덤 프로젝트의 Plan 1개 삭제") {
                        Task {
                            await deleteRandomChild(type: "plans", limit: 1)
                        }
                    }

                    Button("③ 랜덤 프로젝트의 Plan 모두 삭제") {
                        Task {
                            await deleteRandomChild(type: "plans", limit: nil)
                        }
                    }

                    Button("④ 랜덤 프로젝트의 Bookmark 1개 삭제") {
                        Task {
                            await deleteRandomChild(type: "bookmarks", limit: 1)
                        }
                    }

                    Button("⑤ 랜덤 프로젝트 1개 삭제") {
                        Task {
                            await deleteRandomProjects(count: 1)
                        }
                    }

                    Button("⑥ 랜덤 프로젝트 3개 삭제") {
                        Task {
                            await deleteRandomProjects(count: 3)
                        }
                    }
                }

                if let error = errorMessage {
                    Section(header: Text("에러")) {
                        Text("Error - \(error)").foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("🔥 디버깅 전용")
        }
    }

    // MARK: - 삭제 유틸

    func deleteRandomChild(type: String, limit: Int?) async {
        do {
            let projectSnapshot = try await db.collection("Rootrip").getDocuments()
            guard let randomProject = projectSnapshot.documents.randomElement() else { return }
            let projectID = randomProject.documentID

            let subRef = db.collection("Rootrip").document(projectID).collection(type)
            let subSnapshot = try await subRef.getDocuments()

            let docsToDelete = limit != nil ? Array(subSnapshot.documents.prefix(limit!)) : subSnapshot.documents

            for doc in docsToDelete {
                if type == "plans" {
                    try await repository2.deletePlan(projectID: projectID, planID: doc.documentID)
                } else if type == "bookmarks" {
                    try await repository3.deleteBookmark(projectID: projectID, bookmarkID: doc.documentID)
                }
            }
        } catch {
            errorMessage = "deleteRandomChild Error - \(error.localizedDescription)"
        }
    }

    func deleteRandomProjects(count: Int) async {
        do {
            let snapshot = try await db.collection("Rootrip").getDocuments()
            let shuffled = snapshot.documents.shuffled().prefix(count)

            for doc in shuffled {
                try await repository1.deleteProject(projectID: doc.documentID)
            }
        } catch {
            errorMessage = "deleteRandomProjects Error - \(error.localizedDescription)"
        }
    }
}

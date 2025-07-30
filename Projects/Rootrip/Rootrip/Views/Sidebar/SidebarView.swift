//
//  SidebarView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI

struct SidebarView: View {
    @State private var selectedIndex = 0
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var isEditing = false

    let projectID: String

    var body: some View {
        VStack(spacing: 0) {
            // 상단 툴바 영역
            HStack {
                if selectedIndex != 2 {
                    if isEditing {
                        Button(action: {
                            Task {
                                if selectedIndex == 0 {
                                    // 선택된 항목이 있을 때만 삭제 수행
                                    let hasSelectedPlans = !planManager
                                        .selectedPlanIDsForEdit.isEmpty
                                    let hasSelectedPlaces = !planManager
                                        .selectedForDeletionPlaceIDs.isEmpty

                                    if hasSelectedPlans || hasSelectedPlaces {
                                        // 선택된 Plan 섹션들 삭제
                                        for planID in planManager
                                            .selectedPlanIDsForEdit
                                        {
                                            await planManager.deletePlanSection(
                                                projectID: projectID,
                                                planID: planID
                                            )
                                        }
                                        // 선택된 개별 장소들 삭제
                                        for placeID in planManager
                                            .selectedForDeletionPlaceIDs
                                        {
                                            await planManager.deletePlace(
                                                projectID: projectID,
                                                placeID: placeID
                                            )
                                        }

                                        // 선택 상태 초기화
                                        planManager.selectedPlanIDsForEdit
                                            .removeAll()
                                        planManager.selectedForDeletionPlaceIDs
                                            .removeAll()

                                        // 삭제가 실행된 경우에만 편집 모드 종료
                                        DispatchQueue.main.asyncAfter(
                                            deadline: .now() + 0.2
                                        ) {
                                            isEditing = false
                                        }
                                    }
                                    // 아무것도 선택되지 않았으면 아무 일도 하지 않음 (편집 모드 유지)
                                } else if selectedIndex == 1 {
                                    // 북마크 삭제 로직
                                    let hasSelectedBookmarks = !bookmarkManager
                                        .selectedBookmarkIDsForEdit.isEmpty
                                    let hasSelectedPlaces = !bookmarkManager
                                        .selectedForDeletionPlaceIDs.isEmpty

                                    if hasSelectedBookmarks || hasSelectedPlaces
                                    {
                                        // 선택된 Plan 섹션들 삭제
                                        for bookmarkID in bookmarkManager
                                            .selectedBookmarkIDsForEdit
                                        {
                                            await bookmarkManager
                                                .deleteBookmarkSection(
                                                    projectID: projectID,
                                                    bookmarkID: bookmarkID
                                                )
                                        }
                                        // 선택된 개별 장소들 삭제
                                        for placeID in bookmarkManager
                                            .selectedForDeletionPlaceIDs
                                        {
                                            await bookmarkManager.deletePlace(
                                                projectID: projectID,
                                                placeID: placeID
                                            )
                                        }

                                        // 선택 상태 초기화
                                        bookmarkManager
                                            .selectedBookmarkIDsForEdit
                                            .removeAll()
                                        bookmarkManager
                                            .selectedForDeletionPlaceIDs
                                            .removeAll()

                                        // 삭제가 실행된 경우에만 편집 모드 종료
                                        DispatchQueue.main.asyncAfter(
                                            deadline: .now() + 0.2
                                        ) {
                                            isEditing = false
                                        }
                                    }
                                }
                            }
                        }) {
                            Text("삭제")
                                .font(.premed16)
                                .foregroundColor(.accent2)
                        }

                        Spacer()

                        Button("완료") {
                            //나중에 순서 바꾸게 되면 추가할 내용
                            isEditing = false

                        }
                        .foregroundColor(.accent3)
                        .font(.premed16)
                    } else {
                        Spacer()

                        Button("편집") {
                            isEditing = true
                        }
                        .foregroundColor(.accent3)
                        .font(.premed16)
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 19)
            .padding(.trailing, 19)

            /// segment control
            if isEditing {
                if selectedIndex == 0 {
                    HStack {
                        Text("일정")
                            .font(.prebold32)
                            .foregroundColor(.primary1)
                            .padding(.vertical, 26)
                            .padding(.horizontal, 20)

                        Spacer()
                    }
                } else if selectedIndex == 1 {
                    HStack {
                        Text("보관함")
                            .font(.prebold32)
                            .foregroundColor(.primary1)
                            .padding(.vertical, 26)
                            .padding(.horizontal, 20)

                        Spacer()
                    }
                }
            } else {
                SegmentedContolView(
                    selectedIndex: $selectedIndex,
                    projectID: projectID
                )
                .padding(.vertical, 20)

            }
            // MARK: - Child View Rendering (선택된 탭에 따른 하위 뷰 렌더링)
            Group {
                switch selectedIndex {
                case 0: PlanView(isEditing: $isEditing, projectID: projectID)
                case 1:
                    BookmarkView(projectID: projectID, isEditing: $isEditing)
                case 2: ParticipantsView(projectID: projectID)
                default: EmptyView()
                }
            }

            Spacer()
            /// 섹션 추가 버튼
            if isEditing && (selectedIndex == 0 || selectedIndex == 1) {
                Button(action: {
                    Task {
                        if selectedIndex == 0 {
                            // Plan 추가 로직
                            await planManager.createNewPlan(
                                projectID: projectID
                            )
                        } else if selectedIndex == 1 {
                            // Bookmark 추가 로직
                            await bookmarkManager.createNewBookmark(
                                projectID: projectID
                            )
                        }
                    }
                }) {
                    Text("섹션 추가")
                        .font(.prereg16)
                        .foregroundColor(.accent3)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accent3)
                                .background(Color.primary2.cornerRadius(8))
                        )
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
            }

        }
        .frame(width: 216)
        .frame(width: 259)
        .frame(maxHeight: .infinity)
        .background(.mainbackground)
        .transition(.move(edge: .leading))
    }
}

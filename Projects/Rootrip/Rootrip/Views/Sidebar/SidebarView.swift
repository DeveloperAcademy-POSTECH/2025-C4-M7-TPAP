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
                            if selectedIndex == 0 {
                                // 플랜 삭제 로직
                            } else if selectedIndex == 1 {
                                // 북마크 삭제 로직
                            }
                            isEditing = false
                        }) {
                            Text("삭제")
                                .font(.premed16)
                                .foregroundColor(.accent2)
                        }
                        
                        Spacer()
                        
                        Button("완료") {
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
                    
                    Button("편집") {}
                        .hidden()
                        .font(.premed16)
                        .disabled(true)
                }
            }
            .padding(.top, 13)
            .padding(.horizontal, 20)
            
            /// segment control
            if isEditing {
                if selectedIndex == 0 {
                    HStack {
                        Text("일정")
                            .font(.prebold32)
                            .foregroundColor(.primary1)
                            .padding(.vertical, 30)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                } else if selectedIndex == 1 {
                    HStack {
                        Text("보관함")
                            .font(.prebold32)
                            .foregroundColor(.primary1)
                            .padding(.vertical, 30)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            } else {
                SegmentedContolView(selectedIndex: $selectedIndex, projectID: projectID)
                    .padding(.vertical, 20)
                
            }
            // MARK: - Child View Rendering (선택된 탭에 따른 하위 뷰 렌더링)
            Group {
                switch selectedIndex {
                case 0: PlanView(projectID: projectID)
                case 1: BookmarkView(projectID: projectID)// TODO: 북마크 뷰 구현 예정
                case 2: EmptyView()// TODO: 참여자 뷰 구현 예정
                default: EmptyView()
                }
            }
            
            Spacer()
            /// 섹션 추가 버튼
            if isEditing && (selectedIndex == 0 || selectedIndex == 1) {
                Button(action: {
                    if selectedIndex == 0 {
                        // Plan 추가 로직
                    } else if selectedIndex == 1 {
                        // Bookmark 추가 로직
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
        
        .frame(width: 259)
        .frame(maxHeight: .infinity)
        .background(.mainbackground)
        .transition(.move(edge: .leading))
    }
}


//#Preview(traits: .landscapeLeft) {
//        .environmentObject(PlanManager())
//        .environmentObject(LocationManager())
//        .environmentObject(BookmarkManager())
//}

////
////  MapDetailRowView.swift
////  Rootrip
////
////  Created by MINJEONG on 7/24/25.
////
//
//import SwiftUI
/////조건이 함께 있는 UI여서 View로 정의
//// MARK: - 장소 정보 아이템 뷰
//struct MapDetailitem: View {
//    let detail: MapDetail
//    let isSelected: Bool
//    // MARK: - 아이콘 이름 결정 로직
//    var iconName: String {
//        if detail.name.contains("서점") { return "book.fill" }
//        if detail.name.contains("카페") { return "cup.and.saucer.fill" }
//        if detail.name.contains("밥집") { return "fork.knife" }
//        return "mappin"  // 기본값
//    }
//    
//    // MARK: - 사이드바 장소표시(아이콘+장소명)
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: iconName)
//                .frame(width: 40, height: 40)
//                .background(isSelected ? .accent1 : .secondary1)
//                .foregroundColor(.secondary4)
//                .clipShape(Circle())
//                .padding(.trailing, 12)
//            
//            Text(detail.name)
//                .font(.prereg16)
//                .foregroundColor(isSelected ? .accent1 : .maintext)
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        
//    }
//}
//
//#Preview(traits: .landscapeLeft) {
//    MapDetailitem(
//        detail: MapDetail(
//            id: "b1",
//            planID: "planB",
//            name: "카페 로스터리",
//            latitude: 37.5710,
//            longitude: 126.9850
//        ),
//        isSelected: false
//    )
//}

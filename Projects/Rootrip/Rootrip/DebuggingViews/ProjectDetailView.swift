//
//  ProjectDetailView.swift
//  Rootrip
//
//  Created by Ella's Mac on 7/24/25.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project

    var body: some View {
        Text("이건 프로젝트 상세 화면이야!")
        Text("projectTitle: \(project.title)")
        Text("projectID: \(project.id)")
    }
}
//#Preview {
//    ProjectDetailView(projectID: "hi")
//}

//
//  PosterView.swift
//  mond
//
//  Created by ruter on 11.08.26.
//

import SwiftUI
import UniformTypeIdentifiers
import SafariServices
import PartyUI

struct PosterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    
    @State private var show_settings: Bool = false
    @State private var show_importer: Bool = false
    @State private var show_explorer: Bool = false
    @State private var busy = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        apply()
                    } label: {
                        HStack {
                            if busy {
                                ProgressView()
                            }
                            
                            Text("应用")
                        }
                    }
                    .disabled(state.poster_files.isEmpty || busy)

                    if false {
                        Button {
                            reset()
                        } label: {
                            Text("重置")
                        }
                        .disabled(busy)
                    }
                }
                
                Section {
                    Button {
                        show_importer = true
                    } label: {
                        Text("导入壁纸包")
                    }
                    .disabled(busy)
                    
                    Button {
                        show_explorer = true
                    } label: {
                        Text("浏览壁纸包")
                    }
                    .disabled(busy)
                } footer: {
                    Text("最多可导入 5 个壁纸包。\n**注意：** 不建议一次导入超过 5 个；超过 15 个可能导致严重问题。")
                }

                if !state.poster_files.isEmpty {
                    Section {
                        ForEach(state.poster_files, id: \.self) { url in
                            Text(url.lastPathComponent)
                        }
                        .onDelete { offsets in
                            state.remove_poster_files(at: offsets)
                        }
                    } header: {
                        Label("已导入", systemImage: "document.on.document")
                    }
                }
            }
            .navigationTitle("壁纸管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            show_settings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .sheet(isPresented: $show_settings) {
                SettingsView()
            }
            .sheet(isPresented: $show_explorer) {
                TendiesView()
            }
            .fileImporter(isPresented: $show_importer, allowedContentTypes: [.data], allowsMultipleSelection: true) { result in
                switch result {
                case .success(let urls):
                    urls.forEach { state.append_poster_file($0) }
                case .failure(let error):
                    print("(pb) import failed: \(error)")
                }
            }
        }
    }

    private func apply() {
        busy = true
        do {
            let count = try pb.apply(at: state.poster_files)
            print("(pb) applied \(count) descriptor(s).")
            busy = false
            Alertinator.shared.alert(
                title: "壁纸配置已应用！",
                body: "要使更改生效：\n1. 点击“打开”启动 PosterBoard\n2. 从多任务切换器中关闭它",
                actionLabel: "打开",
                action: {
                    // state.respring()
                    
                    let cls = objc_getClass("LSApplicationWorkspace") as? NSObject
                    let ws = cls?.perform(Selector(("defaultWorkspace"))).takeUnretainedValue()
                    _ = ws?.perform(Selector(("openApplicationWithBundleID:")), with: "com.apple.PosterBoard")
                }
            )
        } catch {
            print("(pb) failed: \(error.localizedDescription)\n")
            busy = false
            Alertinator.shared.alert(
                title: "应用壁纸配置失败！",
                body: "请重启应用后重试，并查看运行日志了解详细信息。"
            )
        }
    }

    private func reset() {
        busy = true
        do {
            try pb.reset()
            print("(pb) reset done.")
            busy = false
            Alertinator.shared.alert(
                title: "已恢复壁纸配置！",
                body: "请重新启动系统界面以使更改生效。",
                actionLabel: "Respring",
                action: {
                    state.respring()
                }
            )
        } catch {
            print("(pb) failed: \(error.localizedDescription)")
            busy = false
            Alertinator.shared.alert(
                title: "恢复壁纸配置失败！",
                body: "请重启应用后重试，并查看运行日志了解详细信息。"
            )
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

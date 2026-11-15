//
//  ContentView.swift
//  mond
//
//  Created by ruter on 17.07.26.
//

import SwiftUI
import PartyUI

struct ContentView: View {
    @EnvironmentObject var state: AppState
    @AppStorage("ignore_failure") private var ignore_failure = false
    
    @State private var is_valid: Bool = false
    @State private var show_settings: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .modifier(TerminalPlatter())
                } header: {
                    Label("运行日志", systemImage: "apple.terminal")
                }
                
                Section {
                    NavigationLink {
                        GestaltView()
                    } label: {
                        HStack {
                            Text("设备配置")
                            if state.granting_mg {
                                Spacer()
                                ProgressView()
                                    .tint(Color.primary)
                            }
                        }
                    }
                    .disabled((state.mg_granted != true) && !ignore_failure)
                    
                    NavigationLink {
                        PosterView()
                    } label: {
                        HStack {
                            Text("壁纸管理")
                            if state.granting_pb {
                                Spacer()
                                ProgressView()
                                    .tint(Color.primary)
                            }
                        }
                    }
                    .disabled((state.pb_granted != true) && !ignore_failure)
                    
                    NavigationLink {
                        SantanderView()
                    } label: {
                        HStack {
                            Text("文件管理")
                            if state.granting_apps {
                                Spacer()
                                ProgressView()
                                    .tint(Color.primary)
                            }
                        }
                    }
                    .disabled((state.apps_granted != true) && !ignore_failure)
                } header: {
                    Label("功能调整", systemImage: "paintbrush")
                }
                
                Section {
                    NavigationLink {
                        CEView()
                    } label: {
                        Text("高级配置字段")
                    }
                } header: {
                    Label("高级功能", systemImage: "wrench.and.screwdriver")
                } footer: {
                    Text("仅在了解相关功能时使用这些选项。错误操作可能造成无法恢复的问题。")
                }
            }
            .navigationTitle("mond")
            .tint(Color("AccentColor"))
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
        }
    }
}

//
//  SettingsView.swift
//  mond
//
//  Created by ruter on 18.07.26.
//

import SwiftUI
import PartyUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    
    @AppStorage("method") private var method: String = "worse_query"
    @AppStorage("ka_on") private var ka_on = true
    @AppStorage("token") private var token: String = ""
    @AppStorage("dismiss_after_import") private var dismiss_after_import = false
    @AppStorage("atomic_write") private var atomic_write = true
    @AppStorage("ignore_failure") private var ignore_failure = false
    
    @State private var show_confirm: Bool = false
    
    var valid: Bool {
        (sandbox_extension_consume(token) ?? -1) >= 0
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        if let url = URL(string: "https://github.com/rooootdev/mond"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
                               let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
                               let files = primary["CFBundleIconFiles"] as? [String],
                               let icon = files.last,
                               let img = UIImage(named: icon) {
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                                     ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
                                     ?? "Unknown App")
                                .font(.headline)
                                
                                Text("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                                .imageScale(.small)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                Section {
                    Picker("利用方式", selection: $method) {
                        Text("worse_query").tag("worse_query")
                        Text("bad_query").tag("bad_query")
                    }
                    .pickerStyle(.segmented)

                    Button {
                        grant_all(state: state)
                    } label: {
                        Text("运行利用程序")
                    }
                } header: {
                    Label("利用程序", systemImage: "wrench.and.screwdriver")
                }
                
                Section {
                    TextField("沙盒扩展令牌", text: $token)
                    .contextMenu {
                        Text("类别：\(token.split(separator: ";").first { $0.contains("com.apple") }.map(String.init) ?? "无")")
                        Text("路径：\(token.split(separator: ";").last.map(String.init) ?? "无")")
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Label("复制令牌", systemImage: "doc.on.doc")
                        }
                    }
                    .lineLimit(1)
                    
                    Button {
                        token = sandbox_extension_issue_file(path: TweakPaths.gestalt_dir) ?? "Failed to get token."
                    } label: {
                        Text("生成令牌")
                    }
                    .disabled(!state.exploit_succeeded)
                } header: {
                    Label("令牌", systemImage: "key")
                } footer: {
                    if !token.isEmpty && token != "Failed to get token." {
                        if valid {
                            Text("沙盒令牌有效。")
                        } else {
                            Text("沙盒令牌无效。")
                        }
                    }
                    
                    if !state.exploit_succeeded {
                        Text("利用程序执行失败，功能已禁用。请确认当前 iOS 版本是否受支持。")
                    }
                }
                
                Section {
                    PlainToggle(text: "后台保持运行", infoType: .info, infoMessage: "关闭应用后仍在后台保持运行。", isOn: $ka_on)
                        .onChange(of: ka_on) { _, enabled in
                            if enabled {
                                keep_alive()
                            } else {
                                let_die()
                            }
                        }

                    PlainToggle(text: "导入后自动关闭", infoType: .info, infoMessage: "启用后，将 .tendies 文件导入 PosterBoard 后会自动关闭资源浏览器。", isOn: $dismiss_after_import)

                    PlainToggle(text: "重启后保留修改", infoType: .info, infoMessage: "启用后会在原文件位置写入 MobileGestalt，尝试避免重启时系统重新生成缓存。关闭后使用原子文件替换。", isOn: $atomic_write)
                    
                    PlainToggle(text: "忽略利用程序失败", infoType: .info, infoMessage: "启用后，即使利用程序失败，也允许访问所有调整功能。", isOn: $ignore_failure)
                } header: {
                    Label("设置", systemImage: "gear")
                }
                
                Section {
                    Button {
                        show_confirm = true
                    } label: {
                        Text("重启界面")
                    }
                } header: {
                    Label("工具", systemImage: "wrench.and.screwdriver")
                } footer: {
                    Text("界面重启方案：neon；Swift 实现：skadz。")
                }
                
                Section {
                    CreditsRow(name: "roooot", role: "主要开发者", profile: URL(string: "https://github.com/rooootdev")!)
                    CreditsRow(name: "forcequit", role: "bad/worse_query 沙盒逃逸", profile: URL(string: "https://github.com/forcequitOS")!)
                    CreditsRow(name: "johnny", role: "MCM 漏洞类别相关研究", profile: URL(string: "https://github.com/0xjohnnydev")!)
                    CreditsRow(name: "jailbreak.party", role: "PartyUI 与 GestaltView", profile: URL(string: "https://github.com/jailbreakdotparty")!)
                    CreditsRow(name: "SerStars", role: "Tendies 资源库", profile: URL(string: "https://github.com/SerStars")!)
                } header: {
                    Label("致谢", systemImage: "person.3.fill")
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("完成")
                        }
                    }
                }
            }
            .alert("确定要继续吗？", isPresented: $show_confirm) {
                Button("取消") {
                    show_confirm = false
                }
                
                Button("确认") {
                    state.respring()
                }
            } message: {
                Text("确认重新启动系统界面。")
            }
        }
    }
}

struct CreditsRow: View {
    let name: String
    let role: String
    let profile: URL

    private var pfp: URL? {
        URL(string: profile.absoluteString + ".png")
    }

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: pfp) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)

                Text(role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .onTapGesture {
            UIApplication.shared.open(profile)
        }
    }
}

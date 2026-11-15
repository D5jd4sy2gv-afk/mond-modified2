//
//  GestaltView.swift
//  mond
//
//  Created by ruter on 11.08.26.
//

import SwiftUI
import PartyUI

private extension mg_tweak.InfoType {
    var party_info_type: ToggleInfoType {
        switch self {
            case .info: return .info
            case .warning, .error: return .warning
        }
    }
}

struct TweakToggle: View {
    let title: String

    var body: some View {
        if let tweak = tweak(title) {
            PlainToggle(
                text: tweak.title,
                infoType: tweak.info_t?.party_info_type ?? .none,
                infoMessage: tweak.info_msg ?? "",
                minSupportedVersion: tweak.minv ?? 0.0,
                isOn: mg_tweak_binding(tweak)
            )
        }
    }
}

fileprivate func mg_ui_state() -> (String, Bool, String, String) {
    (selected_st, enable_device_name, mg_device_name, product_type)
}

fileprivate func mg_apply_ui_state(_ selected: String, _ enableName: Bool, _ deviceName: String, _ product: String) {
    selected_st = selected
    enable_device_name = enableName
    mg_device_name = deviceName
    product_type = product
}

struct GestaltView: View {
    @EnvironmentObject var state: AppState

    @State private var show_settings: Bool = false

    @State private var selected_st: String = "og"
    @State private var enable_device_name: Bool = false
    @State private var mg_device_name: String = ""
    @State private var product_type: String = ""
    @State private var tweak_version: Int = 0
    @State private var full_island_subtype: Int? = nil

    var body: some View {
        NavigationStack {
            List {
                if !is_valid || is_empty {
                    Section {
                        if is_empty {
                            PlainAlert(title: "请勿重启！", icon: "exclamationmark.triangle.fill", text: "MobileGestalt.plist 文件似乎为空。", color: Color.yellow)
                        }

                        if !is_valid {
                            PlainAlert(title: "请勿重启！", icon: "exclamationmark.triangle.fill", text: "MobileGestalt.plist 文件似乎无效。", color: Color.yellow)
                        }
                    } header: {
                        Label("警告", systemImage: "exclamationmark.triangle")
                    } footer: {
                        Text("现在重启可能导致设备无法正常启动。请先尝试点击“恢复原始设置”。如果警告仍未消失，请勿重启。")
                    }
                }

                Section {
                    Button {
                        mg_apply_ui_state(selected_st, enable_device_name, mg_device_name, product_type)
                        full_dynamic_island_subtype = full_island_subtype
                        mg_apply()
                        tweak_version += 1
                    } label: {
                        Text("应用修改")
                    }

                    Button {
                        mg_revert()
                        full_island_subtype = nil
                        tweak_version += 1
                    } label: {
                        Text("恢复原始设置")
                    }
                    
                    Button {
                        state.respring()
                    } label: {
                        Text("重启界面")
                    }
                } footer: {
                    Text("**警告：** 不当使用这些调整可能导致设备功能异常，甚至造成软砖。")
                }

                Section {
                    Picker(selection: $selected_st) {
                        Text("原始设备（\(og_st)）").tag("og")

                        if is_device_good() {
                            Text("关闭灵动岛").tag("no_dynamic_island")
                        }

                        Text("iPhone 14 Pro").tag("14p")
                        Text("iPhone 14 Pro Max").tag("14pm")
                        Text("iPhone 15 Pro Max").tag("15pm")

                        if doubleSystemVersion() >= 18.0 {
                            Text("iPhone 16 Pro").tag("16p")
                            Text("iPhone 16 Pro Max").tag("16pm")
                        }

                        if doubleSystemVersion() >= 26.0 {
                            Text("iPhone Air").tag("air")
                        }
                        
                        if doubleSystemVersion() >= 27.0 {
                            Text("iPhone Duo").tag("duo")
                        }

                        if has_home_button() {
                            Text("iPhone X 手势").tag("x")
                        }
                    } label: {
                        HStack {
                            Text("设备外观型号")
                            Spacer()
                        }
                    }

                    Toggle("自定义设备名称", isOn: $enable_device_name)

                    if enable_device_name {
                        TextField("设备名称", text: $mg_device_name)
                    }
                } header: {
                    Label("设备外观", systemImage: "paintbrush.pointed")
                }

                Section {
                    Picker("灵动岛设备布局", selection: $full_island_subtype) {
                        Text("不覆盖原版设置").tag(Int?.none)
                        Text("iPhone 14 Pro（2556）").tag(Int?.some(2556))
                        Text("iPhone 14 Pro Max（2796）").tag(Int?.some(2796))
                        Text("iPhone 16 Pro（2622）").tag(Int?.some(2622))
                        Text("iPhone 16 Pro Max（2868）").tag(Int?.some(2868))
                        Text("iPhone Air（2736）").tag(Int?.some(2736))
                    }
                    .pickerStyle(.menu)
                    Text("此选项单独覆盖 ArtworkDeviceSubType；不会替换上方原版设备外观选项。应用后需注销界面或重启。实际效果取决于系统版本与设备硬件。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Label("满血版灵动岛", systemImage: "capsule.portrait")
                }

                Section {
                    TweakToggle(title: "启用灵动岛功能")
                    TweakToggle(title: "全天候显示")
                    TweakToggle(title: "全天候显示色彩增强")
                    TweakToggle(title: "关闭壁纸视差效果")
                    TweakToggle(title: "充电上限菜单")
                    TweakToggle(title: "开机与关机提示音")
                    TweakToggle(title: "启用液态玻璃低性能模式")
                    TweakToggle(title: "关闭液态玻璃低性能模式")
                } header: {
                    Label("软件功能", systemImage: "gearshape")
                }

                Section {
                    TweakToggle(title: "iPhone 16 相机控制设置")
                    TweakToggle(title: "操作按钮设置")
                    TweakToggle(title: "碰撞检测 SOS")
                    if has_home_button() {
                        TweakToggle(title: "轻点唤醒")
                    }
                    TweakToggle(title: "脉宽调制")
                } header: {
                    Label("硬件功能", systemImage: "iphone")
                }

                Section {
                    TweakToggle(title: "安全研究设备模式")
                    TweakToggle(title: "关闭地区限制")
                    TweakToggle(title: "Apple Intelligence")

                    HStack(spacing: 10) {
                        Picker("伪装机型", selection: $product_type) {
                            Text("默认").tag(machine_name())
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                if doubleSystemVersion() >= 17.4 {
                                    Text("iPad Pro 11 英寸（M4）").tag("iPad16,3")
                                    Text("iPad Pro 11 英寸（M4 蜂窝网络版）").tag("iPad16,4")
                                }
                                Text("iPad Pro 11 英寸（第四代）").tag("iPad14,3")
                                Text("iPad Pro 11 英寸（第四代蜂窝网络版）").tag("iPad14,4")
                            } else {
                                // iPhone 11 series
                                Text("iPhone 11").tag("iPhone12,1")
                                Text("iPhone 11 Pro").tag("iPhone12,3")
                                Text("iPhone 11 Pro Max").tag("iPhone12,5")

                                // iPhone 12 series
                                Text("iPhone 12 mini").tag("iPhone13,1")
                                Text("iPhone 12").tag("iPhone13,2")
                                Text("iPhone 12 Pro").tag("iPhone13,3")
                                Text("iPhone 12 Pro Max").tag("iPhone13,4")

                                // iPhone 13 series
                                Text("iPhone 13 mini").tag("iPhone14,4")
                                Text("iPhone 13").tag("iPhone14,5")
                                Text("iPhone 13 Pro").tag("iPhone14,2")
                                Text("iPhone 13 Pro Max").tag("iPhone14,3")

                                // iPhone 14 series
                                Text("iPhone 14").tag("iPhone14,7")
                                Text("iPhone 14 Plus").tag("iPhone14,8")
                                Text("iPhone 14 Pro").tag("iPhone15,2")
                                Text("iPhone 14 Pro Max").tag("iPhone15,3")
                                Text("iPhone 15 Pro").tag("iPhone16,1")
                                Text("iPhone 15 Pro Max").tag("iPhone16,2")
                                if doubleSystemVersion() >= 18.0 {
                                    Text("iPhone 16").tag("iPhone17,3")
                                    Text("iPhone 16 Plus").tag("iPhone17,4")
                                    Text("iPhone 16 Pro").tag("iPhone17,1")
                                    Text("iPhone 16 Pro Max").tag("iPhone17,2")
                                }
                                if doubleSystemVersion() >= 19.0 {
                                    Text("iPhone 17").tag("iPhone18,3")
                                    Text("iPhone 17 Pro").tag("iPhone18,1")
                                    Text("iPhone 17 Pro Max").tag("iPhone18,2")
                                    Text("iPhone Air").tag("iPhone18,4")
                                }
                                if doubleSystemVersion() >= 27.0 {
                                    Text("iPhone 18 Pro").tag("iPhone19,2")
                                    Text("iPhone 18 Pro Max").tag("iPhone19,7")
                                    Text("iPhone Duo").tag("iPhone19,4")
                                }
                            }
                        }

                        Button {
                            Alertinator.shared.alert(
                                title: "机型伪装说明",
                                body: "仅在需要下载 Apple Intelligence 时才伪装设备机型。此操作可能影响 Face ID。若恢复原机型后仍想保留 Apple Intelligence，请勿再次进入设置中的 Apple Intelligence 与 Siri 菜单。"
                            )
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Label("设备兼容性", systemImage: "checklist")
                }

                Section {
                    Button {
                        Alertinator.shared.alert(title: "恢复 Face ID", body: "此操作不会修改机型伪装，也不能重建 Secure Enclave 安全配对。请前往：设置 > 面容 ID 与密码，检查并重新设置面容 ID。若系统仍不允许设置，可能需要先恢复真实机型并重启。")
                    } label: {
                        Label("恢复 Face ID", systemImage: "faceid")
                    }
                    Button {
                        Alertinator.shared.alert(title: "恢复听写", body: "此操作只提供听写恢复指引，不会修改机型伪装或 Face ID。请前往：设置 > 通用 > 键盘，打开“启用听写”。如果选项仍然缺失，请先恢复真实机型并重启设备。")
                    } label: {
                        Label("恢复听写", systemImage: "mic")
                    }
                } header: {
                    Label("独立恢复", systemImage: "arrow.counterclockwise")
                } footer: {
                    Text("这两个入口互不影响，不会更改当前伪装机型。系统安全功能仍由 iOS 管理。")
                }

                Section {
                    TweakToggle(title: "允许安装 iPad 应用")
                    TweakToggle(title: "Apple Pencil 设置")

                    if UIDevice.current.userInterfaceIdiom == .pad {
                        TweakToggle(title: "台前调度支持")
                    }

                    TweakToggle(title: "启用 iPadOS 模式")
                        .disabled({
                            let cache_extra = mg_dict_now["CacheExtra"] as? [String: Any]
                            return cache_extra?["+3Uf0Pm5F8Xy7Onyvko0vA"] as? String != "iPhone"
                        }())
                } header: {
                    Label("iPadOS 功能", systemImage: "ipad")
                }

                Section {
                    TweakToggle(title: "内部存储视图")
                    TweakToggle(title: "内部功能")
                    TweakToggle(title: "Apple 内部安装功能")
                } header: {
                    Label("内部功能", systemImage: "ant")
                }
            }
            .navigationTitle("设备配置")
            .tint(Color("AccentColor"))
            .task {
                mg_load()
                while is_loading {
                    try? await Task.sleep(for: .milliseconds(50))
                }
                let s = mg_ui_state()
                selected_st = s.0
                full_island_subtype = full_dynamic_island_subtype
                enable_device_name = s.1
                mg_device_name = s.2
                product_type = s.3
            }
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

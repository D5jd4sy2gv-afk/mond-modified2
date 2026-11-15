//
//  mg.swift
//  mond
//
//  Created by ruter on 16.07.26.
//

import SwiftUI
import PartyUI
import Darwin
import MachO
import UIKit

struct mg_tweak {
    let title: String
    let minv: Double?
    let info_t: InfoType?
    let info_msg: String?
    let can_apply: (NSMutableDictionary) -> String?
    
    let r: (NSMutableDictionary) -> Bool
    let w_on: (NSMutableDictionary) -> Void
    let w_off: (NSMutableDictionary) -> Void
    
    enum InfoType {
        case info
        case warning
        case error
    }
}

extension mg_tweak {
    private static func cache_extra(_ dict: NSMutableDictionary) -> NSMutableDictionary? {
        if let extra = dict["CacheExtra"] as? NSMutableDictionary {
            return extra
        }
        guard let extra = dict["CacheExtra"] as? NSDictionary else { return nil }
        let mutable = NSMutableDictionary(dictionary: extra)
        dict["CacheExtra"] = mutable
        return mutable
    }

    init<T: Equatable>(title: String, minv: Double? = nil, key: String, value: T) {
        self.init(
            title: title,
            minv: minv,
            info_t: nil,
            info_msg: nil,
            can_apply: { _ in nil },
            r: { dict in
                guard let extra = dict["CacheExtra"] as? NSDictionary else { return false }
                return extra[key] as? T == value
            },
            w_on: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                extra[key] = value
            },
            w_off: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                extra.removeObject(forKey: key)
            }
        )
    }

    init<T: Equatable>(title: String, minv: Double? = nil, keys: [String], value: T) {
        self.init(
            title: title,
            minv: minv,
            info_t: nil,
            info_msg: nil,
            can_apply: { _ in nil },
            r: { dict in
                guard let extra = dict["CacheExtra"] as? NSDictionary,
                      let key = keys.first
                else {
                    return false
                }
                return extra[key] as? T == value
            },
            w_on: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                for key in keys {
                    extra[key] = value
                }
            },
            w_off: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                for key in keys {
                    extra.removeObject(forKey: key)
                }
            }
        )
    }

    init<T: Equatable>(title: String, minv: Double? = nil, key: String, value: T, info_t: InfoType, info_msg: String) {
        self.init(
            title: title,
            minv: minv,
            info_t: info_t,
            info_msg: info_msg,
            can_apply: { _ in nil },
            r: { dict in
                guard let extra = dict["CacheExtra"] as? NSDictionary else { return false }
                return extra[key] as? T == value
            },
            w_on: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                extra[key] = value
            },
            w_off: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                extra.removeObject(forKey: key)
            }
        )
    }

    init<T: Equatable>(title: String, minv: Double? = nil, keys: [String], value: T, info_t: InfoType, info_msg: String) {
        self.init(
            title: title,
            minv: minv,
            info_t: info_t,
            info_msg: info_msg,
            can_apply: { _ in nil },
            r: { dict in
                guard let extra = dict["CacheExtra"] as? NSDictionary,
                      let key = keys.first
                else {
                    return false
                }
                return extra[key] as? T == value
            },
            w_on: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                for key in keys {
                    extra[key] = value
                }
            },
            w_off: { dict in
                guard let extra = Self.cache_extra(dict) else { return }
                for key in keys {
                    extra.removeObject(forKey: key)
                }
            }
        )
    }
}

private let region_code_key = "h63QSdBCiT/z0WU6rdQv6Q"
private let region_info_key = "yK+xavymRGZ3xWc1tb8XDg"

let all_tweaks: [mg_tweak] = [
    mg_tweak(title: "启用灵动岛功能", minv: 19.0, key: "YlEtTtHlNesRBMal1CqRaA", value: 1, info_t: .info, info_msg: "另一种启用灵动岛能力的方式，Nugget 也采用了类似方法。"),
    mg_tweak(title: "全天候显示", minv: 18.0, keys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"], value: 1, info_t: .warning, info_msg: "在官方不支持的设备上启用可能增加屏幕烧屏风险。"),
    mg_tweak(title: "全天候显示色彩增强", minv: 18.0, key: "ykpu7qyhqFweVMKtxNylWA", value: 1, info_t: .info, info_msg: "如果全天候显示效果异常，请启用此选项。"),
    mg_tweak(title: "关闭壁纸视差效果", key: "UIParallaxCapability", value: 0, info_t: .info, info_msg: "防止设备倾斜或移动时壁纸随之移动。"),
    mg_tweak(title: "启用液态玻璃低性能模式", minv: 19.0, key: "SAGvsp6O6kAQ4fEfDJpC4Q", value: 1, info_t: .info, info_msg: "适用于 iOS 26 及更新版本。"),
    mg_tweak(title: "关闭液态玻璃低性能模式", minv: 19.0, key: "SAGvsp6O6kAQ4fEfDJpC4Q", value: 0, info_t: .info, info_msg: "不要与上方选项同时启用。"),
    mg_tweak(title: "开机与关机提示音", key: "QHxt+hGLaBPbQJbXiUJX3w", value: 1, info_t: .info, info_msg: "设备开机或关机时播放提示音。"),
    mg_tweak(title: "充电上限菜单", minv: 17.0, key: "37NVydb//GP/GrhuTN+exg", value: 1, info_t: .info, info_msg: "显示设置中的充电上限菜单；是否真正限制充电取决于硬件。"),
    mg_tweak(title: "轻点唤醒", key: "yZf3GTRMGTuwSV/lD7Cagw", value: 1, info_t: .info, info_msg: "适用于原本不支持轻点唤醒的设备，例如部分 iPhone SE。"),
    mg_tweak(title: "iPhone 16 相机控制设置", minv: 18.0, keys: ["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"], value: 1, info_t: .info, info_msg: "显示相机控制设置及相关功能。"),
    mg_tweak(title: "Apple Pencil 设置", key: "yhHcB0iH0d1XzPO/CFd3ow", value: 1, info_t: .info, info_msg: "显示 Apple Pencil 设置页面。"),
    mg_tweak(title: "操作按钮设置", minv: 17.0, key: "cT44WE1EohiwRzhsZ8xEsw", value: 1, info_t: .info, info_msg: "显示操作按钮设置页面。"),
    mg_tweak(title: "碰撞检测 SOS", key: "HCzWusHQwZDea6nNhaKndw", value: 1, info_t: .info, info_msg: "显示 SOS 设置中的碰撞检测选项。"),
    mg_tweak(title: "脉宽调制", minv: 19.0, key: "6IejgN+1Fmu5/QrZFOIeNw", value: 1),
    mg_tweak(title: "安全研究设备模式", minv: 26.0, key: "XYlJKKkj2hztRP1NWWnhlw", value: 1, info_t: .info, info_msg: "将设备标记为 Apple 安全研究设备。"),
    mg_tweak(title: "允许安装 iPad 应用", key: "9MZ5AdH43csAUajl/dU+IQ", value: [1, 2], info_t: .info, info_msg: "允许在 iPhone 上安装 iPad 应用。"),
    mg_tweak(title: "台前调度支持", key: "qeaj75wk3HF4DwQ8qbIi7g", value: 1, info_t: .info, info_msg: "将设备标记为支持台前调度。"),
    mg_tweak(title: "Apple 内部安装功能", key: "EqrsVvjcYDdxHBiQmGhAWw", value: 1, info_t: .warning, info_msg: "启用 Metal HUD 等内部功能，可能导致部分系统服务异常。"),
    mg_tweak(title: "内部存储视图", key: "LBJfwOEzExRxzlAnSuI7eg", value: 1, info_t: .warning, info_msg: "在存储设置中显示内部文件；在部分 iPad 上使用可能有风险。"),
    
    mg_tweak(
        title: "关闭地区限制",
        minv: nil,
        info_t: .info,
        info_msg: "此调整在部分 iOS 版本或设备上可能无效或无法正常工作。",
        can_apply: { _ in nil },
        r: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return false }
            return cache_extra[region_code_key] as? String == "LL" &&
                   cache_extra[region_info_key] as? String == "LL/A"
        },
        w_on: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            Alertinator.shared.alert(title: "警告！", body: "请勿使用此功能规避当地法律法规要求的地区限制（例如关闭依法要求的相机快门声）。请勿将其用于违法用途。")
            cache_extra[region_code_key] = "LL"
            cache_extra[region_info_key] = "LL/A"
        },
        w_off: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            cache_extra.removeObject(forKey: region_code_key)
            cache_extra.removeObject(forKey: region_info_key)
        }
    ),
    
    mg_tweak(
        title: "Apple 智能",
        minv: 18.1,
        info_t: .info,
        info_msg: "使用方法：\n1. 先伪装为 Apple 智能支持列表中相邻的机型。\n2. 再恢复为原机型。\n3. 最后伪装为目标机型，设置中应出现 Apple 智能入口。\n4. 连接电源，并保持设置 > 通用 > iPhone 储存空间页面打开约 1 小时。\n\n注意：完成后不要再次恢复伪装。",
        can_apply: { _ in nil },
        r: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return false }
            return (cache_extra["A62OafQ85EJAiiqKn4agtg"] as? Int) == 1
        },
        w_on: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            cache_extra["A62OafQ85EJAiiqKn4agtg"] = 1
            Alertinator.shared.alert(
                title: "Apple 智能机型伪装",
                body: "使用方法：\n1. 先伪装为 Apple 智能支持列表中相邻的机型。\n2. 再恢复为原机型。\n3. 最后伪装为目标机型，设置中应出现 Apple 智能入口。\n4. 连接电源，并保持设置 > 通用 > iPhone 储存空间页面打开约 1 小时。\n\n注意：完成后不要再次恢复伪装。"
            )
        },
        w_off: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            cache_extra.removeObject(forKey: "A62OafQ85EJAiiqKn4agtg")
        }
    ),
    
    mg_tweak(
        title: "启用 iPadOS 模式",
        minv: nil,
        info_t: .warning,
        info_msg: "实验性高风险功能，可能导致系统严重异常。若设备使用字母数字密码，请勿启用此调整。请勿关闭“台前调度中显示程序坞”，否则设备在横屏时可能陷入启动循环。也有用户报告，启用 iPadOS 界面后点击台前调度可能导致设备进入恢复模式，即使界面看起来没有变化。还可能出现系统不稳定、应用数据意外丢失等问题。请谨慎使用，并确保已有可用备份。",
        can_apply: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData else {
                return "MobileGestalt 中缺少 CacheData。"
            }
            guard cache_data_safe_offset("mtrAoWJ3gsq+I90ZnQ0vQw", in: cache_data) != nil else {
                return "未找到此设备或 iOS 版本对应的 CacheData 偏移量，不支持 iPadOS 模式二进制补丁。"
            }
            return nil
        },
        r: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return false }
            let values: [String: Int] = [
                "mG0AnH/Vy1veoqoLRAIgTA": 1,
                "UCG5MkVahJxG1YULbbd5Bg": 1,
                "ZYqko/XM5zD3XBfN5RmaXA": 1,
                "nVh/gwNpy7Jv1NOk00CMrw": 1,
                "uKc7FPnEO++lVhHWHFlGbQ": 1,
            ]
            return values.allSatisfy { key, value in
                (cache_extra[key] as? Int) == value
            }
        },
        w_on: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData,
                  let cache_extra = dict["CacheExtra"] as? NSMutableDictionary,
                  let value_off = cache_data_safe_offset("mtrAoWJ3gsq+I90ZnQ0vQw", in: cache_data) else { return }
            
            cache_data.mutableBytes.storeBytes(of: 3, toByteOffset: value_off, as: Int.self)
            
            let values: [String: Int] = [
                "mG0AnH/Vy1veoqoLRAIgTA": 1,
                "UCG5MkVahJxG1YULbbd5Bg": 1,
                "ZYqko/XM5zD3XBfN5RmaXA": 1,
                "nVh/gwNpy7Jv1NOk00CMrw": 1,
                "uKc7FPnEO++lVhHWHFlGbQ": 1,
            ]
            
            for (key, value) in values {
                cache_extra[key] = value
            }
        },
        w_off: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData,
                  let cache_extra = dict["CacheExtra"] as? NSMutableDictionary,
                  let value_off = cache_data_safe_offset("mtrAoWJ3gsq+I90ZnQ0vQw", in: cache_data) else { return }
            
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: value_off, as: Int.self)
            
            let keys = ["mG0AnH/Vy1veoqoLRAIgTA", "UCG5MkVahJxG1YULbbd5Bg", "ZYqko/XM5zD3XBfN5RmaXA", "nVh/gwNpy7Jv1NOk00CMrw", "uKc7FPnEO++lVhHWHFlGbQ"]
            for key in keys {
                cache_extra.removeObject(forKey: key)
            }
        }
    ),
    
    mg_tweak(
        title: "内部功能",
        minv: nil,
        info_t: nil,
        info_msg: nil,
        can_apply: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData else {
                return "MobileGestalt 中缺少 CacheData。"
            }
            let keys = ["EqrsVvjcYDdxHBiQmGhAWw", "Oji6HRoPi7rH7HPdWVakuw", "LBJfwOEzExRxzlAnSuI7eg"]
            for key in keys {
                if cache_data_safe_offset(key, in: cache_data) == nil {
                    return "CacheData offset not found for \(key). 内部功能 binary patch is not supported on this device/iOS version."
                }
            }
            return nil
        },
        r: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData,
                  let off = cache_data_safe_offset("EqrsVvjcYDdxHBiQmGhAWw", in: cache_data) else { return false }
            return cache_data.bytes.load(fromByteOffset: off, as: Int.self) == 1
        },
        w_on: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData,
                  let off_apple_internal_install = cache_data_safe_offset("EqrsVvjcYDdxHBiQmGhAWw", in: cache_data),
                  let off_has_internal_settings_bundle = cache_data_safe_offset("Oji6HRoPi7rH7HPdWVakuw", in: cache_data),
                  let off_internal_build = cache_data_safe_offset("LBJfwOEzExRxzlAnSuI7eg", in: cache_data) else { return }
            
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: off_apple_internal_install, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: off_has_internal_settings_bundle, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: off_internal_build, as: Int.self)
        },
        w_off: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData,
                  let off_apple_internal_install = cache_data_safe_offset("EqrsVvjcYDdxHBiQmGhAWw", in: cache_data),
                  let off_has_internal_settings_bundle = cache_data_safe_offset("Oji6HRoPi7rH7HPdWVakuw", in: cache_data),
                  let off_internal_build = cache_data_safe_offset("LBJfwOEzExRxzlAnSuI7eg", in: cache_data) else { return }
            
            cache_data.mutableBytes.storeBytes(of: 0, toByteOffset: off_apple_internal_install, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 0, toByteOffset: off_has_internal_settings_bundle, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 0, toByteOffset: off_internal_build, as: Int.self)
        }
    )
]

extension mg_tweak {
    func is_on(in dict: NSMutableDictionary) -> Bool { return r(dict) }
    func apply_on(to dict: NSMutableDictionary) { w_on(dict) }
    func apply_off(to dict: NSMutableDictionary) { w_off(dict) }
    
    func supported() -> Bool {
        guard let minv = minv else { return true }
        return doubleSystemVersion() >= minv
    }
}

func is_device_good() -> Bool {
    let supported: [String] = ["iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone17,5"]
    
    if supported.contains(machine_name()) && doubleSystemVersion() < 19.0 {
        return true
    }
    
    return false
}

func machine_name() -> String {
    var sys_info = utsname()
    uname(&sys_info)
    let machine_mirror = Mirror(reflecting: sys_info.machine)
    
    return machine_mirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
}

var _cache_data_offsets: [String: Int] = [:]

func cache_data_offset(_ key: String) -> Int {
    if let cached = _cache_data_offsets[key] {
        return cached
    }

    let lib_mg = "/usr/lib/libMobileGestalt.dylib"
    dlopen(lib_mg, RTLD_GLOBAL)

    var header: UnsafePointer<mach_header_64>?
    for i in 0..<_dyld_image_count() {
        if String(cString: _dyld_get_image_name(i)) == lib_mg {
            header = unsafeBitCast(_dyld_get_image_header(i), to: UnsafePointer<mach_header_64>.self)
            break
        }
    }
    guard let header else { return 0 }

    var text_size = 0
    guard let cstring = getsectiondata(header, "__TEXT", "__cstring", &text_size) else { return 0 }
    let cstr = cstring.withMemoryRebound(to: CChar.self, capacity: text_size) { $0 }

    var key_ptr = cstr
    while Int(key_ptr - cstr) < text_size {
        if String(cString: key_ptr) == key { break }
        key_ptr += strlen(key_ptr) + 1
    }

    var const_size = 0
    var ptr = getsectiondata(header, "__AUTH_CONST", "__const", &const_size)?.withMemoryRebound(to: UInt.self, capacity: const_size / 8) { $0 }
    if ptr == nil {
        ptr = getsectiondata(header, "__DATA_CONST", "__const", &const_size)?.withMemoryRebound(to: UInt.self, capacity: const_size / 8) { $0 }
    }

    guard let ptr else { return 0 }
    for i in 0..<const_size / 8 {
        if ptr[i] == UInt(bitPattern: key_ptr) {
            let offset = Int((ptr.advanced(by: i).withMemoryRebound(to: UInt16.self, capacity: 1) { $0[0x9a / 2] }) << 3)
            _cache_data_offsets[key] = offset
            return offset
        }
    }

    _cache_data_offsets[key] = 0
    return 0
}

func cache_data_safe_offset(_ key: String, in data: NSMutableData) -> Int? {
    let offset = cache_data_offset(key)
    guard offset > 0, offset <= data.length - MemoryLayout<Int>.size else { return nil }
    return offset
}

let state = AppState.shared

let mg_device_name_key = "mg_device_name"
var mg_device_name: String {
    get {
        UserDefaults.standard.string(forKey: mg_device_name_key) ?? ""
    }
    set {
        UserDefaults.standard.set(newValue, forKey: mg_device_name_key)
    }
}

var og_st: Int = 0
var selected_st: String = "og"
// Optional override for the independent full Dynamic Island layout selector.
var full_dynamic_island_subtype: Int? = nil

var selected_st_value: Int {
    switch selected_st {
        case "og":
            return og_st
        case "no_dynamic_island":
            return 0
        case "14p":
            return 2436
        case "14pm":
            return 2796
        case "15pm":
            return 2976
        case "16p":
            return 2622
        case "16pm":
            return 2868
        case "air":
            return 2736
        case "duo":
            return 2088
        case "x":
            return 2436
        default:
            return 0
    }
}

private var st_to_sel: [Int: String] {
    [
        0: "no_dynamic_island",
        2436: "14p",
        2796: "14pm",
        2976: "15pm",
        2622: "16p",
        2868: "16pm",
        2736: "air",
        2088: "duo",
    ]
}

func tweak(_ title: String) -> mg_tweak? {
    all_tweaks.first { $0.title == title }
}

var is_loading: Bool = false
var is_empty: Bool = false

var enable_device_name: Bool = false
var og_device_name: String = ""
var product_type: String = ""

var is_valid: Bool = true

func mg_load() {
    guard !is_loading, mg_dict_now.count == 0 else { return }
    is_loading = true

    let mg_url_now = URL(fileURLWithPath: TweakPaths.gestalt)

    DispatchQueue.global(qos: .userInitiated).async {
        do {
            let file_size = (try? FileManager.default.attributesOfItem(atPath: mg_url_now.path))?[.size] as? UInt64 ?? 0

            let loaded_dict = try NSMutableDictionary(contentsOf: mg_url_now, error: ())

            // this'll cache gestalt and put it in a safe place
            let mg_url_saved = URL(fileURLWithPath: AppPaths.backups).appendingPathComponent("SavedGestalt.plist")

            if !FileManager.default.fileExists(atPath: mg_url_saved.path) {
                try FileManager.default.copyItem(at: mg_url_now, to: mg_url_saved)
            }

            // get og gestalt values
            let mg_saved_dict = try NSMutableDictionary(contentsOf: mg_url_saved, error: ())
            let og_cache_extra = mg_saved_dict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let og_artwork = og_cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()

            guard let og_subtype = og_artwork["ArtworkDeviceSubType"] as? Int else { throw mg_view_err.missing_artwork_st }
            guard let og_device_name = og_artwork["ArtworkDeviceProductDescription"] as? String else { throw mg_view_err.missing_artwork_device_name }

            let cache_extra = loaded_dict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let artwork = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()

            let current_subtype = artwork["ArtworkDeviceSubType"] as? Int ?? og_subtype
            let saved_full_subtype = UserDefaults.standard.object(forKey: "mond_full_island_subtype") as? Int
            let new_full_island_subtype = saved_full_subtype
            let new_selected_st = st_to_sel[current_subtype] ?? "og"
            let new_device_name = artwork["ArtworkDeviceProductDescription"] as? String ?? og_device_name
            let new_enable_device_name = new_device_name != og_device_name

            let new_product_type: String
            if let productType = cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String, !productType.isEmpty {
                new_product_type = productType
            } else {
                new_product_type = machine_name()
            }

            DispatchQueue.main.async {
                mg_dict_now = loaded_dict
                og_st = og_subtype
                selected_st = new_selected_st
                full_dynamic_island_subtype = new_full_island_subtype
                mg_device_name = new_device_name
                enable_device_name = new_enable_device_name
                product_type = new_product_type
                is_valid = true
                is_empty = file_size == 0
                is_loading = false
            }
        } catch {
            DispatchQueue.main.async {
                print("(mg) failed to load data: \(error)")
                is_valid = false
                is_empty = (try? FileManager.default.attributesOfItem(atPath: mg_url_now.path))?[.size] as? UInt64 == 0
                is_loading = false
                Alertinator.shared.alert(title: "无法读取当前 MobileGestalt！", body: "请重新启动应用后重试，并查看运行日志了解详细信息。")
            }
        }
    }
}

func mg_apply() {
    do {
        if let subtype = full_dynamic_island_subtype {
            UserDefaults.standard.set(subtype, forKey: "mond_full_island_subtype")
        } else {
            UserDefaults.standard.removeObject(forKey: "mond_full_island_subtype")
        }
        let cache_extra = mg_dict_now["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
        if !product_type.isEmpty {
            cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] = product_type
        }
        
        let artwork_dict = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()
        artwork_dict["ArtworkDeviceSubType"] = full_dynamic_island_subtype ?? selected_st_value
        if enable_device_name {
            artwork_dict["ArtworkDeviceProductDescription"] = mg_device_name
        }
        
        let data = try PropertyListSerialization.data(fromPropertyList: mg_dict_now, format: .xml, options: 0)

        try mg_write(data)
        mg_reload()
        enable_device_name = false

        print("(mg) successfully overwrote mobilegestalt!")
        Alertinator.shared.alert(title: "MobileGestalt 修改已应用！", body: "请重新启动系统界面使更改生效。部分调整可能需要重启设备。", actionLabel: "重启界面", action: {
            state.respring()
        })
    } catch {
        print("(mg) failed to apply mobilegestalt: \(error)")
        Alertinator.shared.alert(title: "应用 MobileGestalt 修改失败！", body: "请重新启动应用后重试，并查看运行日志了解详细信息。")
    }
}

func mg_revert() {
    do {
        let backup_url = URL(fileURLWithPath: AppPaths.backups).appendingPathComponent("SavedGestalt.plist")
        let backup_data = try Data(contentsOf: backup_url)
        try mg_write(backup_data)
        mg_reload()
        full_dynamic_island_subtype = nil
        UserDefaults.standard.removeObject(forKey: "mond_full_island_subtype")
        selected_st = "og"

        print("(mg) successfully reverted mobilegestalt!)")
        Alertinator.shared.alert(title: "已恢复 MobileGestalt 原始设置！", body: "请重启设备以使更改生效。")
    } catch {
        print("(mg) failed to revert mobilegestalt: \(error)")
        Alertinator.shared.alert(title: "恢复 MobileGestalt 失败！", body: "请查看运行日志了解错误详情。")
    }
}

func mg_reload() {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: TweakPaths.gestalt)),
          let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? NSMutableDictionary else { return }
    mg_dict_now = dict
}

private enum mg_write_err: Error {
    case open(errno: Int32)
    case truncate(errno: Int32)
    case write(errno: Int32)
    case sync(errno: Int32)
    case rollback(errno: Int32)
    case verificationFailed
}

private func read_all(_ fd: Int32) throws -> Data {
    var res = Data()
    var buf = [UInt8](repeating: 0, count: 64 * 1024)

    while true {
        let count = buf.withUnsafeMutableBytes { rawBuffer in
            read(fd, rawBuffer.baseAddress, rawBuffer.count)
        }

        if count > 0 {
            res.append(buf, count: count)
            continue
        }

        if count == 0 {
            return res
        }

        if errno == EINTR {
            continue
        }

        throw mg_write_err.verificationFailed
    }
}

private func write_all(_ fd: Int32, _ data: Data) throws {
    guard !data.isEmpty else { return }

    try data.withUnsafeBytes { rawBuffer in
        guard let base = rawBuffer.baseAddress else {
            throw mg_write_err.write(errno: EFAULT)
        }

        var offset = 0

        while offset < data.count {
            let res = write(
                fd,
                base.advanced(by: offset),
                data.count - offset
            )

            if res > 0 {
                offset += res
                continue
            }

            if res < 0 && errno == EINTR {
                continue
            }

            throw mg_write_err.write(errno: errno)
        }
    }
}

func mg_write(_ data: Data, to path: String) throws {
    let og = try Data(contentsOf: URL(fileURLWithPath: path))

    let fd = path.withCString {
        open($0, O_RDWR | O_CLOEXEC | O_NOFOLLOW)
    }

    guard fd >= 0 else {
        throw mg_write_err.open(errno: errno)
    }

    defer {
        close(fd)
    }

    do {
        guard ftruncate(fd, 0) == 0 else {
            throw mg_write_err.truncate(errno: errno)
        }

        try write_all(fd, data)

        guard fsync(fd) == 0 else {
            throw mg_write_err.sync(errno: errno)
        }

        guard lseek(fd, 0, SEEK_SET) >= 0 else {
            throw mg_write_err.verificationFailed
        }

        let verify = try read_all(fd)

        guard verify == data else {
            throw mg_write_err.verificationFailed
        }
    } catch {
        if ftruncate(fd, 0) == 0,
           lseek(fd, 0, SEEK_SET) >= 0 {
            _ = try? write_all(fd, og)
            _ = fsync(fd)
        }

        throw error
    }
}


func mg_write(_ data: Data) throws {
    let path = TweakPaths.gestalt

    if UserDefaults.standard.bool(forKey: "atomic_write") {
        try mg_write(data, to: path)
    } else {
        let target_url = URL(fileURLWithPath: path)
        let temp_url = target_url.deletingLastPathComponent()
            .appendingPathComponent(".\(target_url.lastPathComponent).\(UUID().uuidString).tmp")

        try data.write(to: temp_url, options: [.withoutOverwriting])
        defer { try? fm.removeItem(at: temp_url) }

        if fm.fileExists(atPath: target_url.path) {
            _ = try fm.replaceItemAt(target_url, withItemAt: temp_url)
        } else {
            try fm.moveItem(at: temp_url, to: target_url)
        }
    }
}

var mg_dict_now: NSMutableDictionary = NSMutableDictionary()

func mg_tweak_binding(_ tweak: mg_tweak) -> Binding<Bool> {
    Binding(
        get: {
            tweak.is_on(in: mg_dict_now)
        },
        set: { enabled in
            if let error = tweak.can_apply(mg_dict_now) {
                Alertinator.shared.alert(title: "无法应用：\(tweak.title)", body: error)
                return
            }
            if enabled {
                tweak.apply_on(to: mg_dict_now)
            } else {
                tweak.apply_off(to: mg_dict_now)
            }
        }
    )
}

enum mg_view_err: Error, LocalizedError {
    case missing_artwork_st
    case missing_artwork_device_name
    
    var errorDescription: String? {
        switch self {
            case .missing_artwork_st:
                return "无法读取 ArtworkDeviceSubType！"
            case .missing_artwork_device_name:
                return "无法读取 ArtworkDeviceProductDescription！"
        }
    }
}

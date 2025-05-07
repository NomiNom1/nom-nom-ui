// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "NomiNom",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "NomiNom",
            targets: ["NomiNom"]),
    ],
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", from: "16.0.0"),
        .package(url: "https://github.com/WeChatDeveloper/WeChatSDK.git", from: "1.8.7")
    ],
    targets: [
        .target(
            name: "NomiNom",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
                .product(name: "WechatOpenSDK", package: "WeChatSDK")
            ]),
        .testTarget(
            name: "NomiNomTests",
            dependencies: ["NomiNom"]),
    ]
) 
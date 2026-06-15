// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Mosaic",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Mosaic", targets: ["Mosaic"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            from: "10.0.0"
        )
    ],
    targets: [
        .target(
            name: "Mosaic",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Mosaic"
        )
    ]
)

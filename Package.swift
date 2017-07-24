import PackageDescription

let package = Package(
    name: "Elasticsearch",
    targets: [
        Target(name: "Elasticsearch"),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/node.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/json.git", majorVersion: 2),
    ]
)



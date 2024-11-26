import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "host.docker.internal",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "root",
        database: Environment.get("DATABASE_NAME") ?? "chatdatabase",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    app.http.server.configuration.hostname = "0.0.0.0"
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom("http://localhost:3000"), // Ваш клієнтський додаток
        allowedMethods: [.GET, .POST, .DELETE, .OPTIONS], // Методи
        allowedHeaders: [.accept, .authorization, .contentType, .origin] // Дозволені заголовки
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)

    app.middleware.use(corsMiddleware)
    app.middleware.use(ErrorMiddleware.default(environment: app.environment)) 
    
    app.migrations.add(CreateChat())
    app.migrations.add(CreateMessage())
    // register routes
    try routes(app)
}
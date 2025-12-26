var builder = DistributedApplication.CreateBuilder(args);

var apiService = builder.AddProject<Projects.Galactic_Code_Website_Project_VISUALSTUDIO2026_ApiService>("apiservice")
    .WithHttpHealthCheck("/health");

builder.AddProject<Projects.Galactic_Code_Website_Project_VISUALSTUDIO2026_Web>("webfrontend")
    .WithExternalHttpEndpoints()
    .WithHttpHealthCheck("/health")
    .WithReference(apiService)
    .WaitFor(apiService);

builder.Build().Run();

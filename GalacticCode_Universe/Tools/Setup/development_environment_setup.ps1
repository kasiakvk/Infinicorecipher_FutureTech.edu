# Development Environment Setup for InfiniCoreCipher
# Skrypt konfiguracji środowiska deweloperskiego

param(
    [string]$BasePath = "D:\InfiniCoreCipher-Startup-BACKUP-20251212"
)

Write-Host "=== DEVELOPMENT ENVIRONMENT SETUP ===" -ForegroundColor Cyan
Write-Host "Lokalizacja: $BasePath" -ForegroundColor Yellow

cd "$BasePath\development"

# === IDE CONFIGURATIONS ===
Write-Host "`n=== KONFIGURACJE IDE ===" -ForegroundColor Green
cd "ide-configs"

# Visual Studio Code
mkdir "vscode" -Force | Out-Null
cd "vscode"

$vscodeSettings = @"
{
    "workbench.colorTheme": "Dark+ (default dark)",
    "editor.fontSize": 14,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.wordWrap": "on",
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "extensions.autoUpdate": true,
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "terminal.integrated.defaultProfile.windows": "PowerShell",
    "python.defaultInterpreterPath": "python",
    "javascript.updateImportsOnFileMove.enabled": "always",
    "typescript.updateImportsOnFileMove.enabled": "always",
    "emmet.includeLanguages": {
        "javascript": "javascriptreact",
        "typescript": "typescriptreact"
    }
}
"@

$vscodeSettings | Out-File "settings.json" -Encoding UTF8

$vscodeExtensions = @"
{
    "recommendations": [
        "ms-python.python",
        "ms-vscode.cpptools",
        "ms-dotnettools.csharp",
        "bradlc.vscode-tailwindcss",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-typescript-next",
        "ms-vscode.vscode-json",
        "redhat.vscode-yaml",
        "ms-vscode.powershell",
        "gitpod.gitpod-desktop",
        "github.copilot",
        "ms-vscode-remote.remote-containers",
        "ms-azuretools.vscode-docker",
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "humao.rest-client",
        "ms-vscode.hexeditor",
        "streetsidesoftware.code-spell-checker",
        "gruntfuggly.todo-tree",
        "ms-vscode.live-server"
    ]
}
"@

$vscodeExtensions | Out-File "extensions.json" -Encoding UTF8

cd ..

# Visual Studio
mkdir "visual-studio" -Force | Out-Null
cd "visual-studio"

$vsConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    </packageSources>
    <config>
        <add key="globalPackagesFolder" value="packages" />
    </config>
</configuration>
"@

$vsConfig | Out-File "nuget.config" -Encoding UTF8

cd ..

# JetBrains IDEs
mkdir "jetbrains" -Force | Out-Null
cd "jetbrains"

$jetbrainsConfig = @"
# JetBrains IDEs Configuration

## Recommended IDEs:
- IntelliJ IDEA Ultimate (Java/Kotlin)
- WebStorm (JavaScript/TypeScript)
- PyCharm Professional (Python)
- Rider (C#/.NET)
- CLion (C/C++)

## Plugins:
- GitToolBox
- Rainbow Brackets
- Key Promoter X
- String Manipulation
- .ignore
- Docker
- Kubernetes
- Database Tools and SQL
"@

$jetbrainsConfig | Out-File "README.md" -Encoding UTF8

cd ..
cd ..

# === BUILD TOOLS ===
Write-Host "`n=== NARZĘDZIA BUDOWANIA ===" -ForegroundColor Green
cd "build-tools"

# Node.js/npm configuration
$packageJson = @"
{
    "name": "infinicorecipher-build-tools",
    "version": "1.0.0",
    "description": "Build tools for InfiniCoreCipher project",
    "scripts": {
        "build": "npm run build:all",
        "build:all": "npm run build:platform && npm run build:games",
        "build:platform": "echo 'Building platform...'",
        "build:games": "npm run build:galactic && npm run build:starlight",
        "build:galactic": "echo 'Building GalacticCode Universe...'",
        "build:starlight": "echo 'Building Starlight Universe...'",
        "test": "npm run test:all",
        "test:all": "npm run test:unit && npm run test:integration",
        "test:unit": "jest --testPathPattern=unit",
        "test:integration": "jest --testPathPattern=integration",
        "lint": "eslint . --ext .js,.ts,.jsx,.tsx",
        "lint:fix": "eslint . --ext .js,.ts,.jsx,.tsx --fix",
        "format": "prettier --write .",
        "dev": "concurrently \"npm run dev:platform\" \"npm run dev:games\"",
        "dev:platform": "echo 'Starting platform dev server...'",
        "dev:games": "echo 'Starting games dev servers...'"
    },
    "devDependencies": {
        "@types/node": "^20.0.0",
        "@typescript-eslint/eslint-plugin": "^6.0.0",
        "@typescript-eslint/parser": "^6.0.0",
        "concurrently": "^8.0.0",
        "eslint": "^8.0.0",
        "jest": "^29.0.0",
        "prettier": "^3.0.0",
        "typescript": "^5.0.0",
        "webpack": "^5.0.0",
        "webpack-cli": "^5.0.0"
    }
}
"@

$packageJson | Out-File "package.json" -Encoding UTF8

# Webpack configuration
$webpackConfig = @"
const path = require('path');

module.exports = {
    entry: {
        platform: './src/platform/index.js',
        galactic: './src/games/galactic/index.js',
        starlight: './src/games/starlight/index.js'
    },
    output: {
        path: path.resolve(__dirname, '../../output/dist'),
        filename: '[name].bundle.js'
    },
    module: {
        rules: [
            {
                test: /\.tsx?$/,
                use: 'ts-loader',
                exclude: /node_modules/
            },
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
            },
            {
                test: /\.(png|svg|jpg|jpeg|gif)$/i,
                type: 'asset/resource'
            }
        ]
    },
    resolve: {
        extensions: ['.tsx', '.ts', '.js']
    },
    devServer: {
        contentBase: './dist',
        hot: true
    }
};
"@

$webpackConfig | Out-File "webpack.config.js" -Encoding UTF8

# TypeScript configuration
$tsConfig = @"
{
    "compilerOptions": {
        "target": "ES2020",
        "module": "commonjs",
        "lib": ["ES2020", "DOM"],
        "outDir": "../../output/dist",
        "rootDir": "../../src",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "declaration": true,
        "declarationMap": true,
        "sourceMap": true,
        "removeComments": false,
        "noImplicitAny": true,
        "strictNullChecks": true,
        "strictFunctionTypes": true,
        "noImplicitReturns": true,
        "noFallthroughCasesInSwitch": true,
        "moduleResolution": "node",
        "baseUrl": ".",
        "paths": {
            "@platform/*": ["../../platform/*"],
            "@games/*": ["../../games/*"],
            "@shared/*": ["../../repositories/shared-libraries/*"]
        }
    },
    "include": [
        "../../src/**/*",
        "../../platform/**/*",
        "../../games/**/*"
    ],
    "exclude": [
        "node_modules",
        "../../output/**/*",
        "../../temp/**/*"
    ]
}
"@

$tsConfig | Out-File "tsconfig.json" -Encoding UTF8

cd ..

# === CI/CD ===
Write-Host "`n=== CI/CD KONFIGURACJA ===" -ForegroundColor Green
cd "ci-cd"

mkdir "github-actions" -Force | Out-Null
cd "github-actions"

$githubWorkflow = @"
name: InfiniCoreCipher CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js `${{ matrix.node-version }}`
      uses: actions/setup-node@v3
      with:
        node-version: `${{ matrix.node-version }}`
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linting
      run: npm run lint
    
    - name: Run tests
      run: npm run test
    
    - name: Build project
      run: npm run build

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run security audit
      run: npm audit
    
    - name: Run Snyk security scan
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: `${{ secrets.SNYK_TOKEN }}`

  deploy-staging:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to staging
      run: echo "Deploying to staging environment"

  deploy-production:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: echo "Deploying to production environment"
"@

$githubWorkflow | Out-File "ci-cd.yml" -Encoding UTF8

cd ..
cd ..

# === DOCKER ===
Write-Host "`n=== DOCKER KONFIGURACJA ===" -ForegroundColor Green
cd "docker"

$dockerfile = @"
# Multi-stage Dockerfile for InfiniCoreCipher

# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY src/ ./src/
COPY platform/ ./platform/
COPY games/ ./games/

# Build application
RUN npm run build

# Production stage
FROM node:18-alpine AS production

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S infinicore -u 1001

# Copy built application
COPY --from=builder --chown=infinicore:nodejs /app/dist ./dist
COPY --from=builder --chown=infinicore:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=infinicore:nodejs /app/package.json ./

# Switch to non-root user
USER infinicore

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["node", "dist/index.js"]
"@

$dockerfile | Out-File "Dockerfile" -Encoding UTF8

$dockerCompose = @"
version: '3.8'

services:
  infinicore-platform:
    build:
      context: ../..
      dockerfile: development/docker/Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/infinicore
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - ../../src:/app/src
      - ../../platform:/app/platform
    networks:
      - infinicore-network

  galactic-game:
    build:
      context: ../../games/GalacticCode_Universe
      dockerfile: Dockerfile
    ports:
      - "3001:3000"
    environment:
      - NODE_ENV=development
      - PLATFORM_API_URL=http://infinicore-platform:3000
    depends_on:
      - infinicore-platform
    networks:
      - infinicore-network

  starlight-game:
    build:
      context: ../../games/Starlight_Universe
      dockerfile: Dockerfile
    ports:
      - "3002:3000"
    environment:
      - NODE_ENV=development
      - PLATFORM_API_URL=http://infinicore-platform:3000
    depends_on:
      - infinicore-platform
    networks:
      - infinicore-network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=infinicore
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    networks:
      - infinicore-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - infinicore-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ../../assets:/usr/share/nginx/html/assets
    depends_on:
      - infinicore-platform
      - galactic-game
      - starlight-game
    networks:
      - infinicore-network

volumes:
  postgres_data:
  redis_data:

networks:
  infinicore-network:
    driver: bridge
"@

$dockerCompose | Out-File "docker-compose.yml" -Encoding UTF8

cd ..

# === MONITORING ===
Write-Host "`n=== MONITORING KONFIGURACJA ===" -ForegroundColor Green
cd "monitoring"

$prometheusConfig = @"
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'infinicore-platform'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'galactic-game'
    static_configs:
      - targets: ['localhost:3001']
    metrics_path: '/metrics'

  - job_name: 'starlight-game'
    static_configs:
      - targets: ['localhost:3002']
    metrics_path: '/metrics'

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
"@

$prometheusConfig | Out-File "prometheus.yml" -Encoding UTF8

cd ..

Write-Host "`n=== DEVELOPMENT ENVIRONMENT GOTOWY! ===" -ForegroundColor Green
Write-Host "✅ IDE configurations" -ForegroundColor Green
Write-Host "✅ Build tools" -ForegroundColor Green
Write-Host "✅ CI/CD pipelines" -ForegroundColor Green
Write-Host "✅ Docker containers" -ForegroundColor Green
Write-Host "✅ Monitoring setup" -ForegroundColor Green

Write-Host "`n📋 NASTĘPNE KROKI:" -ForegroundColor Yellow
Write-Host "1. Zainstaluj Node.js i npm" -ForegroundColor Gray
Write-Host "2. Uruchom: npm install w build-tools/" -ForegroundColor Gray
Write-Host "3. Skonfiguruj IDE używając plików z ide-configs/" -ForegroundColor Gray
Write-Host "4. Uruchom Docker: docker-compose up -d" -ForegroundColor Gray
Write-Host "5. Rozpocznij development!" -ForegroundColor Gray
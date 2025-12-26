# Create-Full-Project-Setup.ps1
# Pełna konfiguracja projektu InfiniCoreCipher-Startup od podstaw

param(
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup",
    [switch]$Force = $false,
    [switch]$SkipNpmInstall = $false,
    [string]$ProjectName = "infinicorecipher-startup"
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Magenta"
$Magenta = "Magenta"

Write-Host "🚀 TWORZENIE PEŁNEJ KONFIGURACJI PROJEKTU" -ForegroundColor $Cyan
Write-Host "=========================================" -ForegroundColor $Cyan
Write-Host "Ścieżka: $ProjectPath" -ForegroundColor $Yellow
Write-Host "Nazwa: $ProjectName" -ForegroundColor $Yellow
Write-Host ""

# Sprawdź wymagania systemowe
Write-Host "🔍 SPRAWDZANIE WYMAGAŃ SYSTEMOWYCH" -ForegroundColor $Cyan

$Requirements = @()

# Node.js
try {
    $NodeVersion = node --version 2>$null
    if ($NodeVersion) {
        Write-Host "   ✅ Node.js: $NodeVersion" -ForegroundColor $Green
    } else {
        Write-Host "   ❌ Node.js nie jest zainstalowany" -ForegroundColor $Red
        $Requirements += "Node.js - https://nodejs.org/"
    }
} catch {
    Write-Host "   ❌ Node.js nie jest dostępny" -ForegroundColor $Red
    $Requirements += "Node.js - https://nodejs.org/"
}

# npm
try {
    $NpmVersion = npm --version 2>$null
    if ($NpmVersion) {
        Write-Host "   ✅ npm: v$NpmVersion" -ForegroundColor $Green
    } else {
        Write-Host "   ❌ npm nie jest dostępny" -ForegroundColor $Red
        $Requirements += "npm (instaluje się z Node.js)"
    }
} catch {
    Write-Host "   ❌ npm nie jest dostępny" -ForegroundColor $Red
    $Requirements += "npm (instaluje się z Node.js)"
}

# Git (opcjonalnie)
try {
    $GitVersion = git --version 2>$null
    if ($GitVersion) {
        Write-Host "   ✅ $GitVersion" -ForegroundColor $Green
    } else {
        Write-Host "   ⚠️  Git nie jest zainstalowany (opcjonalny)" -ForegroundColor $Yellow
    }
} catch {
    Write-Host "   ⚠️  Git nie jest zainstalowany (opcjonalny)" -ForegroundColor $Yellow
}

if ($Requirements.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ BRAKUJĄCE WYMAGANIA:" -ForegroundColor $Red
    foreach ($Req in $Requirements) {
        Write-Host "   - $Req" -ForegroundColor $Red
    }
    Write-Host ""
    Write-Host "Zainstaluj brakujące komponenty i uruchom skrypt ponownie." -ForegroundColor $Yellow
    exit 1
}

Write-Host ""

# Sprawdź czy folder istnieje
if (Test-Path $ProjectPath) {
    if (-not $Force) {
        Write-Host "⚠️  Folder już istnieje: $ProjectPath" -ForegroundColor $Yellow
        $Response = Read-Host "Czy chcesz kontynuować? Istniejące pliki mogą zostać nadpisane. (y/N)"
        
        if ($Response -ne "y" -and $Response -ne "Y") {
            Write-Host "Operacja anulowana przez użytkownika." -ForegroundColor $Yellow
            exit 0
        }
    }
    
    # Utwórz kopię zapasową
    $BackupPath = "$ProjectPath-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "📦 Tworzenie kopii zapasowej: $BackupPath" -ForegroundColor $Yellow
    try {
        Copy-Item -Path $ProjectPath -Destination $BackupPath -Recurse -Force
        Write-Host "✅ Kopia zapasowa utworzona" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Błąd kopii zapasowej: $($_.Exception.Message)" -ForegroundColor $Red
    }
} else {
    Write-Host "📁 Tworzenie folderu projektu..." -ForegroundColor $Yellow
    try {
        New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
        Write-Host "✅ Folder utworzony" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Błąd tworzenia folderu: $($_.Exception.Message)" -ForegroundColor $Red
        exit 1
    }
}

# Przejdź do folderu projektu
Push-Location $ProjectPath

try {
    Write-Host ""
    Write-Host "📋 TWORZENIE STRUKTURY PROJEKTU" -ForegroundColor $Cyan
    
    # Struktura folderów
    $Folders = @(
        "frontend",
        "frontend/src",
        "frontend/src/components",
        "frontend/src/pages",
        "frontend/src/hooks",
        "frontend/src/utils",
        "frontend/src/types",
        "frontend/src/styles",
        "frontend/src/assets",
        "frontend/public",
        "backend",
        "backend/src",
        "backend/src/routes",
        "backend/src/controllers",
        "backend/src/services",
        "backend/src/models",
        "backend/src/middleware",
        "backend/src/utils",
        "backend/src/types",
        "backend/src/config",
        "database",
        "database/schemas",
        "database/migrations",
        "database/seeds",
        "docs",
        "docs/api",
        "config"
    )
    
    Write-Host "📁 Tworzenie folderów..." -ForegroundColor $Yellow
    foreach ($Folder in $Folders) {
        try {
            New-Item -ItemType Directory -Path $Folder -Force | Out-Null
            Write-Host "   ✅ $Folder" -ForegroundColor $Green
        } catch {
            Write-Host "   ❌ $Folder - $($_.Exception.Message)" -ForegroundColor $Red
        }
    }
    
    Write-Host ""
    Write-Host "📄 TWORZENIE PLIKÓW KONFIGURACYJNYCH" -ForegroundColor $Cyan
    
    # Root package.json
    Write-Host "📦 Tworzenie root package.json..." -ForegroundColor $Yellow
    $RootPackageJson = @{
        name = $ProjectName
        version = "1.0.0"
        description = "Educational gaming platform for children with neurodiversity (ADHD, Autism)"
        main = "index.js"
        scripts = @{
            "dev" = "concurrently `"npm run dev:backend`" `"npm run dev:frontend`""
            "dev:frontend" = "cd frontend && npm run dev"
            "dev:backend" = "cd backend && npm run dev"
            "build" = "npm run build:frontend && npm run build:backend"
            "build:frontend" = "cd frontend && npm run build"
            "build:backend" = "cd backend && npm run build"
            "install:all" = "npm install && cd frontend && npm install && cd ../backend && npm install"
            "clean" = "rimraf frontend/node_modules backend/node_modules node_modules frontend/dist backend/dist"
            "test" = "npm run test:frontend && npm run test:backend"
            "test:frontend" = "cd frontend && npm run test"
            "test:backend" = "cd backend && npm run test"
        }
        keywords = @("education", "neurodiversity", "ADHD", "autism", "accessibility", "games", "children")
        author = "InfiniCoreCipher Team"
        license = "MIT"
        devDependencies = @{
            "concurrently" = "^8.2.2"
            "rimraf" = "^5.0.5"
        }
        workspaces = @("frontend", "backend")
    }
    
    $RootPackageJson | ConvertTo-Json -Depth 10 | Out-File -FilePath "package.json" -Encoding UTF8
    Write-Host "   ✅ package.json" -ForegroundColor $Green
    
    # Frontend package.json
    Write-Host "📦 Tworzenie frontend package.json..." -ForegroundColor $Yellow
    $FrontendPackageJson = @{
        name = "infinicorecipher-frontend"
        private = $true
        version = "0.0.0"
        type = "module"
        scripts = @{
            "dev" = "vite"
            "build" = "tsc && vite build"
            "lint" = "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
            "preview" = "vite preview"
            "test" = "vitest"
        }
        dependencies = @{
            "react" = "^18.2.0"
            "react-dom" = "^18.2.0"
            "react-router-dom" = "^6.20.1"
            "react-helmet-async" = "^1.3.0"
            "react-hot-toast" = "^2.4.1"
            "framer-motion" = "^10.16.5"
            "react-icons" = "^4.12.0"
            "@headlessui/react" = "^1.7.17"
            "clsx" = "^2.0.0"
        }
        devDependencies = @{
            "@types/react" = "^18.2.37"
            "@types/react-dom" = "^18.2.15"
            "@typescript-eslint/eslint-plugin" = "^6.10.0"
            "@typescript-eslint/parser" = "^6.10.0"
            "@vitejs/plugin-react" = "^4.1.1"
            "autoprefixer" = "^10.4.16"
            "eslint" = "^8.53.0"
            "eslint-plugin-react-hooks" = "^4.6.0"
            "eslint-plugin-react-refresh" = "^0.4.4"
            "postcss" = "^8.4.31"
            "tailwindcss" = "^3.3.5"
            "typescript" = "^5.2.2"
            "vite" = "^4.5.0"
            "vitest" = "^0.34.6"
        }
    }
    
    $FrontendPackageJson | ConvertTo-Json -Depth 10 | Out-File -FilePath "frontend/package.json" -Encoding UTF8
    Write-Host "   ✅ frontend/package.json" -ForegroundColor $Green
    
    # Backend package.json
    Write-Host "📦 Tworzenie backend package.json..." -ForegroundColor $Yellow
    $BackendPackageJson = @{
        name = "infinicorecipher-backend"
        version = "1.0.0"
        description = "Backend API for InfiniCoreCipher educational platform"
        main = "dist/server.js"
        scripts = @{
            "dev" = "nodemon src/server.ts"
            "build" = "tsc"
            "start" = "node dist/server.js"
            "test" = "jest"
            "test:watch" = "jest --watch"
            "lint" = "eslint src --ext .ts"
            "lint:fix" = "eslint src --ext .ts --fix"
        }
        dependencies = @{
            "express" = "^4.18.2"
            "cors" = "^2.8.5"
            "helmet" = "^7.1.0"
            "morgan" = "^1.10.0"
            "dotenv" = "^16.3.1"
            "bcryptjs" = "^2.4.3"
            "jsonwebtoken" = "^9.0.2"
            "joi" = "^17.11.0"
            "pg" = "^8.11.3"
            "socket.io" = "^4.7.4"
        }
        devDependencies = @{
            "@types/express" = "^4.17.21"
            "@types/cors" = "^2.8.17"
            "@types/morgan" = "^1.9.9"
            "@types/bcryptjs" = "^2.4.6"
            "@types/jsonwebtoken" = "^9.0.5"
            "@types/pg" = "^8.10.9"
            "@types/node" = "^20.9.0"
            "@typescript-eslint/eslint-plugin" = "^6.10.0"
            "@typescript-eslint/parser" = "^6.10.0"
            "eslint" = "^8.53.0"
            "jest" = "^29.7.0"
            "@types/jest" = "^29.5.8"
            "ts-jest" = "^29.1.1"
            "nodemon" = "^3.0.1"
            "ts-node" = "^10.9.1"
            "typescript" = "^5.2.2"
        }
    }
    
    $BackendPackageJson | ConvertTo-Json -Depth 10 | Out-File -FilePath "backend/package.json" -Encoding UTF8
    Write-Host "   ✅ backend/package.json" -ForegroundColor $Green
    
    # README.md
    Write-Host "📄 Tworzenie README.md..." -ForegroundColor $Yellow
    $ReadmeContent = @"
# InfiniCoreCipher - Educational Platform for Neurodiversity

## 🌟 Overview

InfiniCoreCipher is an innovative educational gaming platform designed specifically for children with neurodiversity, including ADHD, Autism, and other learning differences. Our mission is to provide a safe, accessible, and engaging learning environment that adapts to each child's unique needs.

## 🎯 Features

### 🧠 Neurodiversity Support
- **ADHD-friendly tools**: Focus timers, break reminders, task breakdown
- **Autism support**: Sensory-friendly modes, calm colors, reduced stimuli
- **Dyslexia support**: Special fonts, reading guides, simplified interfaces
- **Universal accessibility**: Screen reader support, keyboard navigation, high contrast modes

### 🎮 Educational Games
- **Galactic Code**: Learn programming concepts in space
- **Starlight Math**: Mathematical adventures among the stars
- **Focus Quest**: Attention and concentration training games
- **Social Skills Galaxy**: Interactive social learning experiences

### 👨‍👩‍👧‍👦 Parent Dashboard
- Real-time progress tracking
- Detailed analytics and insights
- Customizable accessibility settings
- Communication tools with educators

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ 
- npm 8+
- PostgreSQL 13+

### Installation

1. **Clone and setup**
   \`\`\`bash
   git clone <repository-url>
   cd infinicorecipher-startup
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   npm run install:all
   \`\`\`

3. **Configure environment**
   \`\`\`bash
   cp config/development.env.example .env
   # Edit .env with your database credentials
   \`\`\`

4. **Setup database**
   \`\`\`bash
   # Run migrations
   npm run db:migrate
   
   # Seed sample data
   npm run db:seed
   \`\`\`

5. **Start development servers**
   \`\`\`bash
   npm run dev
   \`\`\`

### Access the application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **API Documentation**: http://localhost:5000/api/docs

## 📁 Project Structure

\`\`\`
infinicorecipher-startup/
├── frontend/          # React + TypeScript frontend
│   ├── src/
│   │   ├── components/    # Reusable UI components
│   │   ├── pages/         # Page components
│   │   ├── hooks/         # Custom React hooks
│   │   ├── utils/         # Utility functions
│   │   └── types/         # TypeScript type definitions
│   └── public/        # Static assets
├── backend/           # Node.js + Express backend
│   ├── src/
│   │   ├── routes/        # API route handlers
│   │   ├── controllers/   # Business logic
│   │   ├── services/      # Data services
│   │   ├── models/        # Data models
│   │   ├── middleware/    # Express middleware
│   │   └── config/        # Configuration files
├── database/          # Database schemas and migrations
│   ├── schemas/       # SQL schema definitions
│   ├── migrations/    # Database migrations
│   └── seeds/         # Sample data
├── docs/              # Documentation
└── config/            # Environment configurations
\`\`\`

## 🛠️ Development

### Available Scripts

\`\`\`bash
# Development
npm run dev              # Start both frontend and backend
npm run dev:frontend     # Start only frontend
npm run dev:backend      # Start only backend

# Building
npm run build            # Build both frontend and backend
npm run build:frontend   # Build only frontend
npm run build:backend    # Build only backend

# Testing
npm run test             # Run all tests
npm run test:frontend    # Run frontend tests
npm run test:backend     # Run backend tests

# Maintenance
npm run clean            # Clean all node_modules and build files
npm run install:all      # Install all dependencies
\`\`\`

### Environment Variables

Create a \`.env\` file in the root directory:

\`\`\`env
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/infinicorecipher
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=infinicorecipher
DATABASE_USER=your_username
DATABASE_PASSWORD=your_password

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d

# Server
PORT=5000
NODE_ENV=development

# Frontend
VITE_API_URL=http://localhost:5000/api
\`\`\`

## 🎨 Accessibility Features

### Visual Accessibility
- High contrast themes
- Customizable font sizes
- Dyslexia-friendly fonts (OpenDyslexic)
- Reduced motion options
- Color-blind friendly palettes

### Motor Accessibility
- Keyboard navigation support
- Sticky keys support
- Touch-friendly interface (44px minimum touch targets)
- Voice control compatibility

### Cognitive Accessibility
- Simplified interface modes
- Reading guides and focus indicators
- Break reminders and focus timers
- Task breakdown and progress indicators
- Clear, consistent navigation

### Sensory Accessibility
- Sensory-friendly color schemes
- Reduced stimuli modes
- Customizable sound settings
- Calm, soothing visual themes

## 🧪 Testing

### Frontend Testing
\`\`\`bash
cd frontend
npm run test        # Run tests
npm run test:watch  # Run tests in watch mode
\`\`\`

### Backend Testing
\`\`\`bash
cd backend
npm run test        # Run tests
npm run test:watch  # Run tests in watch mode
\`\`\`

## 📚 Documentation

- [API Documentation](docs/api/README.md)
- [Accessibility Guide](docs/ACCESSIBILITY.md)
- [Setup Guide](docs/SETUP.md)
- [Deployment Guide](docs/deployment/README.md)

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Special thanks to the neurodiversity community for their invaluable feedback
- Accessibility consultants who helped shape our inclusive design
- Open source libraries that make this project possible

## 📞 Support

- **Documentation**: Check our [docs](docs/) folder
- **Issues**: Report bugs on GitHub Issues
- **Email**: support@infinicorecipher.com

---

**Made with ❤️ for neurodivergent learners everywhere**
"@

    $ReadmeContent | Out-File -FilePath "README.md" -Encoding UTF8
    Write-Host "   ✅ README.md" -ForegroundColor $Green
    
    # .gitignore
    Write-Host "📄 Tworzenie .gitignore..." -ForegroundColor $Yellow
    $GitignoreContent = @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
out/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Cache
.cache/
.parcel-cache/
.vite/

# Coverage
coverage/

# Temporary files
*.tmp
*.temp

# Database
*.sqlite
*.db

# Backup files
*-backup-*
"@

    $GitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
    Write-Host "   ✅ .gitignore" -ForegroundColor $Green
    
    # Frontend index.html
    Write-Host "📄 Tworzenie frontend/index.html..." -ForegroundColor $Yellow
    $IndexHtmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <link rel="icon" type="image/svg+xml" href="/vite.svg" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="description" content="InfiniCoreCipher - Educational platform for children with neurodiversity" />
  <title>InfiniCoreCipher - Educational Platform</title>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.tsx"></script>
</body>
</html>
"@

    $IndexHtmlContent | Out-File -FilePath "frontend/index.html" -Encoding UTF8
    Write-Host "   ✅ frontend/index.html" -ForegroundColor $Green
    
    # Vite config
    Write-Host "📄 Tworzenie vite.config.ts..." -ForegroundColor $Yellow
    $ViteConfigContent = @"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@types': path.resolve(__dirname, './src/types'),
      '@styles': path.resolve(__dirname, './src/styles'),
      '@assets': path.resolve(__dirname, './src/assets'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
})
"@

    $ViteConfigContent | Out-File -FilePath "frontend/vite.config.ts" -Encoding UTF8
    Write-Host "   ✅ frontend/vite.config.ts" -ForegroundColor $Green
    
    # Backend server.ts
    Write-Host "📄 Tworzenie backend/src/server.ts..." -ForegroundColor $Yellow
    $ServerTsContent = @"
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import dotenv from 'dotenv'

// Load environment variables
dotenv.config()

const app = express()
const PORT = process.env.PORT || 5000

// Middleware
app.use(helmet())
app.use(cors())
app.use(morgan('combined'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'InfiniCoreCipher API'
  })
})

// API routes
app.get('/api', (req, res) => {
  res.json({ 
    message: 'Welcome to InfiniCoreCipher API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api'
    }
  })
})

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  })
})

// Error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack)
  res.status(500).json({ 
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong!'
  })
})

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`)
  console.log(`📚 API documentation: http://localhost:${PORT}/api`)
  console.log(`❤️  Health check: http://localhost:${PORT}/health`)
})

export default app
"@

    $ServerTsContent | Out-File -FilePath "backend/src/server.ts" -Encoding UTF8
    Write-Host "   ✅ backend/src/server.ts" -ForegroundColor $Green
    
    # TypeScript configs
    Write-Host "📄 Tworzenie plików TypeScript..." -ForegroundColor $Yellow
    
    # Frontend tsconfig.json
    $FrontendTsConfig = @{
        compilerOptions = @{
            target = "ES2020"
            useDefineForClassFields = $true
            lib = @("ES2020", "DOM", "DOM.Iterable")
            module = "ESNext"
            skipLibCheck = $true
            moduleResolution = "bundler"
            allowImportingTsExtensions = $true
            resolveJsonModule = $true
            isolatedModules = $true
            noEmit = $true
            jsx = "react-jsx"
            strict = $true
            noUnusedLocals = $true
            noUnusedParameters = $true
            noFallthroughCasesInSwitch = $true
            baseUrl = "."
            paths = @{
                "@/*" = @("./src/*")
                "@components/*" = @("./src/components/*")
                "@pages/*" = @("./src/pages/*")
                "@hooks/*" = @("./src/hooks/*")
                "@utils/*" = @("./src/utils/*")
                "@types/*" = @("./src/types/*")
                "@styles/*" = @("./src/styles/*")
                "@assets/*" = @("./src/assets/*")
            }
        }
        include = @("src")
        references = @(@{ path = "./tsconfig.node.json" })
    }
    
    $FrontendTsConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath "frontend/tsconfig.json" -Encoding UTF8
    Write-Host "   ✅ frontend/tsconfig.json" -ForegroundColor $Green
    
    # Backend tsconfig.json
    $BackendTsConfig = @{
        compilerOptions = @{
            target = "ES2020"
            module = "commonjs"
            lib = @("ES2020")
            outDir = "./dist"
            rootDir = "./src"
            strict = $true
            esModuleInterop = $true
            skipLibCheck = $true
            forceConsistentCasingInFileNames = $true
            resolveJsonModule = $true
            declaration = $true
            declarationMap = $true
            sourceMap = $true
            removeComments = $true
            noImplicitAny = $true
            noImplicitReturns = $true
            noFallthroughCasesInSwitch = $true
            noUnusedLocals = $true
            noUnusedParameters = $true
            exactOptionalPropertyTypes = $true
            baseUrl = "."
            paths = @{
                "@/*" = @("./src/*")
                "@routes/*" = @("./src/routes/*")
                "@controllers/*" = @("./src/controllers/*")
                "@services/*" = @("./src/services/*")
                "@models/*" = @("./src/models/*")
                "@middleware/*" = @("./src/middleware/*")
                "@utils/*" = @("./src/utils/*")
                "@types/*" = @("./src/types/*")
                "@config/*" = @("./src/config/*")
            }
        }
        include = @("src/**/*")
        exclude = @("node_modules", "dist", "**/*.test.ts", "**/*.spec.ts")
    }
    
    $BackendTsConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath "backend/tsconfig.json" -Encoding UTF8
    Write-Host "   ✅ backend/tsconfig.json" -ForegroundColor $Green
    
    Write-Host ""
    
    # Instalacja zależności
    if (-not $SkipNpmInstall) {
        Write-Host "📦 INSTALACJA ZALEŻNOŚCI" -ForegroundColor $Cyan
        
        # Root dependencies
        Write-Host "📁 Instalacja zależności root..." -ForegroundColor $Yellow
        try {
            npm install --silent 2>$null
            Write-Host "   ✅ Root dependencies zainstalowane" -ForegroundColor $Green
        } catch {
            Write-Host "   ❌ Błąd instalacji root: $($_.Exception.Message)" -ForegroundColor $Red
        }
        
        # Frontend dependencies
        Write-Host "📁 Instalacja zależności frontend..." -ForegroundColor $Yellow
        try {
            Push-Location "frontend"
            npm install --silent 2>$null
            Write-Host "   ✅ Frontend dependencies zainstalowane" -ForegroundColor $Green
        } catch {
            Write-Host "   ❌ Błąd instalacji frontend: $($_.Exception.Message)" -ForegroundColor $Red
        } finally {
            Pop-Location
        }
        
        # Backend dependencies
        Write-Host "📁 Instalacja zależności backend..." -ForegroundColor $Yellow
        try {
            Push-Location "backend"
            npm install --silent 2>$null
            Write-Host "   ✅ Backend dependencies zainstalowane" -ForegroundColor $Green
        } catch {
            Write-Host "   ❌ Błąd instalacji backend: $($_.Exception.Message)" -ForegroundColor $Red
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "⏭️  Pomijanie instalacji npm (użyto -SkipNpmInstall)" -ForegroundColor $Yellow
        Write-Host "Uruchom później: npm run install:all" -ForegroundColor $Yellow
    }
    
    Write-Host ""
    Write-Host "🎉 PROJEKT UTWORZONY POMYŚLNIE!" -ForegroundColor $Green
    Write-Host ""
    
    # Sprawdź rozmiar projektu
    try {
        $ProjectSize = (Get-ChildItem -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $ProjectSizeMB = [math]::Round($ProjectSize / 1MB, 2)
        $FileCount = (Get-ChildItem -Recurse -File).Count
        
        Write-Host "📊 STATYSTYKI PROJEKTU:" -ForegroundColor $Cyan
        Write-Host "   📁 Rozmiar: $ProjectSizeMB MB" -ForegroundColor $Yellow
        Write-Host "   📄 Pliki: $FileCount" -ForegroundColor $Yellow
        Write-Host "   📂 Foldery: $($Folders.Count)" -ForegroundColor $Yellow
    } catch {
        Write-Host "📊 Nie można obliczyć statystyk projektu" -ForegroundColor $Yellow
    }
    
    Write-Host ""
    Write-Host "🚀 NASTĘPNE KROKI:" -ForegroundColor $Cyan
    Write-Host "1. cd `"$ProjectPath`"" -ForegroundColor $Yellow
    
    if ($SkipNpmInstall) {
        Write-Host "2. npm run install:all" -ForegroundColor $Yellow
        Write-Host "3. npm run dev" -ForegroundColor $Yellow
    } else {
        Write-Host "2. npm run dev" -ForegroundColor $Yellow
    }
    
    Write-Host ""
    Write-Host "🌐 APLIKACJA BĘDZIE DOSTĘPNA POD:" -ForegroundColor $Cyan
    Write-Host "   Frontend: http://localhost:3000" -ForegroundColor $Yellow
    Write-Host "   Backend:  http://localhost:5000" -ForegroundColor $Yellow
    Write-Host "   API:      http://localhost:5000/api" -ForegroundColor $Yellow
    Write-Host "   Health:   http://localhost:5000/health" -ForegroundColor $Yellow
    
    Write-Host ""
    Write-Host "📚 DOKUMENTACJA:" -ForegroundColor $Cyan
    Write-Host "   README.md - Główna dokumentacja" -ForegroundColor $Yellow
    Write-Host "   docs/ - Szczegółowa dokumentacja" -ForegroundColor $Yellow
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONFIGURACJA ZAKOŃCZONA ===" -ForegroundColor $Cyan
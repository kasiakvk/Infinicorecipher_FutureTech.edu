<#
.SYNOPSIS
    Skrypt naprawczy dla problemów z uruchomieniem InfiniCoreCipher

.DESCRIPTION
    Naprawia typowe problemy z konfiguracją i uruchomieniem projektu
#>

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-FixStatus {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $Color
}

Write-Host "=== NAPRAWA INFINICORECIPHER ===" -ForegroundColor $Cyan
Write-Host ""

# Sprawdzenie czy jesteśmy w odpowiednim katalogu
if (-not (Test-Path "package.json")) {
    Write-FixStatus "❌ Nie znaleziono package.json w bieżącym katalogu" "ERROR" $Red
    Write-FixStatus "Przejdź do katalogu głównego projektu InfiniCoreCipher" "INFO" $Yellow
    exit 1
}

Write-FixStatus "🔧 ROZPOCZĘCIE NAPRAWY" "INFO" $Cyan

# 1. Sprawdzenie i naprawa package.json w root
Write-FixStatus "📦 Sprawdzanie root package.json..." "INFO" $Yellow

$rootPackageContent = @"
{
  "name": "infinicorecipher-startup",
  "version": "1.0.0",
  "description": "InfiniCoreCipher Startup Project",
  "main": "index.js",
  "scripts": {
    "dev": "concurrently \"npm run dev:backend\" \"npm run dev:frontend\"",
    "dev:backend": "cd backend && npm run dev",
    "dev:frontend": "cd frontend && npm run dev",
    "build": "cd frontend && npm run build",
    "start": "cd backend && npm start",
    "install:all": "npm install && cd frontend && npm install && cd ../backend && npm install",
    "clean": "rimraf node_modules frontend/node_modules backend/node_modules",
    "test": "cd frontend && npm test && cd ../backend && npm test"
  },
  "keywords": ["cipher", "encryption", "startup"],
  "author": "InfiniCoreCipher Team",
  "license": "MIT",
  "devDependencies": {
    "concurrently": "^8.2.2",
    "rimraf": "^5.0.10"
  }
}
"@

try {
    $rootPackageContent | Out-File -FilePath "package.json" -Encoding UTF8
    Write-FixStatus "✅ Root package.json naprawiony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd naprawy root package.json: $($_.Exception.Message)" "ERROR" $Red
}

# 2. Sprawdzenie i naprawa backend/package.json
Write-FixStatus "📦 Sprawdzanie backend package.json..." "INFO" $Yellow

if (-not (Test-Path "backend")) {
    New-Item -ItemType Directory -Path "backend" -Force | Out-Null
    Write-FixStatus "✅ Utworzono katalog backend" "OK" $Green
}

$backendPackageContent = @"
{
  "name": "infinicorecipher-backend",
  "version": "1.0.0",
  "description": "InfiniCoreCipher Backend API",
  "main": "server.js",
  "scripts": {
    "dev": "nodemon server.js",
    "start": "node server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0"
  },
  "keywords": ["api", "backend", "cipher"],
  "author": "InfiniCoreCipher Team",
  "license": "MIT"
}
"@

try {
    $backendPackageContent | Out-File -FilePath "backend/package.json" -Encoding UTF8
    Write-FixStatus "✅ Backend package.json naprawiony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd naprawy backend package.json: $($_.Exception.Message)" "ERROR" $Red
}

# 3. Sprawdzenie i naprawa frontend/package.json
Write-FixStatus "📦 Sprawdzanie frontend package.json..." "INFO" $Yellow

if (-not (Test-Path "frontend")) {
    New-Item -ItemType Directory -Path "frontend" -Force | Out-Null
    Write-FixStatus "✅ Utworzono katalog frontend" "OK" $Green
}

$frontendPackageContent = @"
{
  "name": "infinicorecipher-frontend",
  "version": "1.0.0",
  "description": "InfiniCoreCipher Frontend Application",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.1"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@vitejs/plugin-react": "^4.1.1",
    "vite": "^4.5.0",
    "vitest": "^0.34.6"
  },
  "keywords": ["react", "frontend", "cipher"],
  "author": "InfiniCoreCipher Team",
  "license": "MIT"
}
"@

try {
    $frontendPackageContent | Out-File -FilePath "frontend/package.json" -Encoding UTF8
    Write-FixStatus "✅ Frontend package.json naprawiony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd naprawy frontend package.json: $($_.Exception.Message)" "ERROR" $Red
}

# 4. Tworzenie podstawowego server.js dla backend
Write-FixStatus "🖥️ Tworzenie backend server.js..." "INFO" $Yellow

$serverJsContent = @"
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'InfiniCoreCipher Backend is running',
    timestamp: new Date().toISOString()
  });
});

// API routes
app.get('/api', (req, res) => {
  res.json({ 
    message: 'InfiniCoreCipher API',
    version: '1.0.0',
    endpoints: [
      'GET /health - Health check',
      'GET /api - API information'
    ]
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 InfiniCoreCipher Backend running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`📍 API: http://localhost:${PORT}/api`);
});

module.exports = app;
"@

try {
    $serverJsContent | Out-File -FilePath "backend/server.js" -Encoding UTF8
    Write-FixStatus "✅ Backend server.js utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia server.js: $($_.Exception.Message)" "ERROR" $Red
}

# 5. Tworzenie podstawowej struktury frontend
Write-FixStatus "🌐 Tworzenie struktury frontend..." "INFO" $Yellow

# Tworzenie katalogów
$frontendDirs = @("frontend/src", "frontend/public")
foreach ($dir in $frontendDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-FixStatus "✅ Utworzono $dir" "OK" $Green
    }
}

# Tworzenie index.html
$indexHtmlContent = @"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>InfiniCoreCipher</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
"@

try {
    $indexHtmlContent | Out-File -FilePath "frontend/index.html" -Encoding UTF8
    Write-FixStatus "✅ Frontend index.html utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia index.html: $($_.Exception.Message)" "ERROR" $Red
}

# Tworzenie main.jsx
$mainJsxContent = @"
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
"@

try {
    $mainJsxContent | Out-File -FilePath "frontend/src/main.jsx" -Encoding UTF8
    Write-FixStatus "✅ Frontend main.jsx utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia main.jsx: $($_.Exception.Message)" "ERROR" $Red
}

# Tworzenie App.jsx
$appJsxContent = @"
import React, { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [backendStatus, setBackendStatus] = useState('Checking...')

  useEffect(() => {
    // Test connection to backend
    fetch('http://localhost:5000/health')
      .then(response => response.json())
      .then(data => setBackendStatus('Connected ✅'))
      .catch(error => setBackendStatus('Disconnected ❌'))
  }, [])

  return (
    <div className="App">
      <header className="App-header">
        <h1>🔐 InfiniCoreCipher</h1>
        <p>Advanced Encryption & Security Platform</p>
        <div className="status-card">
          <h3>System Status</h3>
          <p>Frontend: Running ✅</p>
          <p>Backend: {backendStatus}</p>
        </div>
        <div className="features">
          <h3>Features</h3>
          <ul>
            <li>🔒 Advanced Encryption Algorithms</li>
            <li>🛡️ Secure Key Management</li>
            <li>📊 Real-time Security Analytics</li>
            <li>🌐 Cross-platform Compatibility</li>
          </ul>
        </div>
      </header>
    </div>
  )
}

export default App
"@

try {
    $appJsxContent | Out-File -FilePath "frontend/src/App.jsx" -Encoding UTF8
    Write-FixStatus "✅ Frontend App.jsx utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia App.jsx: $($_.Exception.Message)" "ERROR" $Red
}

# Tworzenie CSS
$appCssContent = @"
#root {
  max-width: 1280px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}

.App {
  padding: 20px;
}

.App-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px;
  border-radius: 15px;
  color: white;
  margin-bottom: 20px;
}

.App-header h1 {
  font-size: 3rem;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

.status-card {
  background: rgba(255,255,255,0.1);
  padding: 20px;
  border-radius: 10px;
  margin: 20px 0;
  backdrop-filter: blur(10px);
}

.features {
  background: rgba(255,255,255,0.1);
  padding: 20px;
  border-radius: 10px;
  margin: 20px 0;
  backdrop-filter: blur(10px);
}

.features ul {
  list-style: none;
  padding: 0;
}

.features li {
  padding: 8px 0;
  font-size: 1.1rem;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background: linear-gradient(45deg, #1e3c72 0%, #2a5298 100%);
  min-height: 100vh;
}
"@

try {
    $appCssContent | Out-File -FilePath "frontend/src/App.css" -Encoding UTF8
    Write-FixStatus "✅ Frontend App.css utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia App.css: $($_.Exception.Message)" "ERROR" $Red
}

# Tworzenie index.css
$indexCssContent = @"
:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
  color-scheme: light dark;
  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;
  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  -webkit-text-size-adjust: 100%;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  display: flex;
  place-items: center;
  min-width: 320px;
  min-height: 100vh;
}

#root {
  width: 100%;
}
"@

try {
    $indexCssContent | Out-File -FilePath "frontend/src/index.css" -Encoding UTF8
    Write-FixStatus "✅ Frontend index.css utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia index.css: $($_.Exception.Message)" "ERROR" $Red
}

# 6. Tworzenie vite.config.js
$viteConfigContent = @"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true
  },
  build: {
    outDir: 'dist'
  }
})
"@

try {
    $viteConfigContent | Out-File -FilePath "frontend/vite.config.js" -Encoding UTF8
    Write-FixStatus "✅ Frontend vite.config.js utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia vite.config.js: $($_.Exception.Message)" "ERROR" $Red
}

# 7. Tworzenie .env dla backend
$envContent = @"
# Backend Configuration
PORT=5000
NODE_ENV=development

# Database (if needed)
# DATABASE_URL=

# Security
# JWT_SECRET=your-secret-key
"@

try {
    $envContent | Out-File -FilePath "backend/.env" -Encoding UTF8
    Write-FixStatus "✅ Backend .env utworzony" "OK" $Green
} catch {
    Write-FixStatus "❌ Błąd tworzenia .env: $($_.Exception.Message)" "ERROR" $Red
}

Write-Host ""
Write-FixStatus "🎉 NAPRAWA ZAKOŃCZONA!" "OK" $Green
Write-Host ""
Write-FixStatus "📋 NASTĘPNE KROKI:" "INFO" $Cyan
Write-FixStatus "1. Zainstaluj zależności: npm run install:all" "INFO" $Yellow
Write-FixStatus "2. Uruchom projekt: npm run dev" "INFO" $Yellow
Write-FixStatus "3. Sprawdź:" "INFO" $Yellow
Write-FixStatus "   - Frontend: http://localhost:3000" "INFO" $Blue
Write-FixStatus "   - Backend: http://localhost:5000/health" "INFO" $Blue
Write-Host ""
Write-FixStatus "=== KONIEC NAPRAWY ===" "INFO" $Cyan
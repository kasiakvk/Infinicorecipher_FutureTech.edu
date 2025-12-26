# Generate-Missing-Components.ps1
# Generator szkieletów dla brakujących komponentów InfiniCoreCipher

param(
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup",
    [string]$Phase = "1",
    [switch]$Force = $false,
    [switch]$DryRun = $false
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

Write-Host "🏗️  GENERATOR BRAKUJĄCYCH KOMPONENTÓW" -ForegroundColor $Cyan
Write-Host "====================================" -ForegroundColor $Cyan
Write-Host "Projekt: $ProjectPath" -ForegroundColor $Yellow
Write-Host "Faza: $Phase" -ForegroundColor $Yellow
Write-Host "Tryb: $(if($DryRun){'DRY RUN (symulacja)'}else{'PRODUKCJA'})" -ForegroundColor $Yellow
Write-Host ""

if (-not (Test-Path $ProjectPath)) {
    Write-Host "❌ Folder projektu nie istnieje: $ProjectPath" -ForegroundColor $Red
    exit 1
}

Push-Location $ProjectPath

try {
    # Definicja szkieletów komponentów według faz
    $ComponentTemplates = @{
        "1" = @{
            "backend/src/app.ts" = @"
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import dotenv from 'dotenv'
import { errorHandler } from './middleware/errorHandler'
import { authMiddleware } from './middleware/auth'

// Import routes
import authRoutes from './routes/auth'
import userRoutes from './routes/users'
import gameRoutes from './routes/games'

// Load environment variables
dotenv.config()

const app = express()

// Security middleware
app.use(helmet())
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}))

// Logging
app.use(morgan('combined'))

// Body parsing
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'InfiniCoreCipher API',
    version: '1.0.0'
  })
})

// API routes
app.use('/api/auth', authRoutes)
app.use('/api/users', authMiddleware, userRoutes)
app.use('/api/games', authMiddleware, gameRoutes)

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  })
})

// Error handling middleware
app.use(errorHandler)

export default app
"@
            "backend/src/config/database.ts" = @"
import { Pool } from 'pg'
import dotenv from 'dotenv'

dotenv.config()

// Database configuration
const dbConfig = {
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT || '5432'),
  database: process.env.DATABASE_NAME || 'infinicorecipher',
  user: process.env.DATABASE_USER || 'postgres',
  password: process.env.DATABASE_PASSWORD || 'password',
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error after 2 seconds if connection could not be established
}

// Create connection pool
export const pool = new Pool(dbConfig)

// Test database connection
export const testConnection = async (): Promise<boolean> => {
  try {
    const client = await pool.connect()
    await client.query('SELECT NOW()')
    client.release()
    console.log('✅ Database connection successful')
    return true
  } catch (error) {
    console.error('❌ Database connection failed:', error)
    return false
  }
}

// Initialize database
export const initializeDatabase = async (): Promise<void> => {
  try {
    await testConnection()
    
    // Run basic health check
    const client = await pool.connect()
    const result = await client.query('SELECT version()')
    console.log('📊 Database version:', result.rows[0].version)
    client.release()
    
  } catch (error) {
    console.error('❌ Database initialization failed:', error)
    throw error
  }
}

// Graceful shutdown
export const closeDatabase = async (): Promise<void> => {
  try {
    await pool.end()
    console.log('🔌 Database connection pool closed')
  } catch (error) {
    console.error('❌ Error closing database:', error)
  }
}

export default pool
"@
            "backend/src/models/User.ts" = @"
export interface User {
  id: string
  email: string
  username: string
  password_hash: string
  first_name: string
  last_name: string
  date_of_birth?: Date
  neurodiversity_type?: string[]
  accessibility_settings?: AccessibilitySettings
  parent_email?: string
  is_active: boolean
  created_at: Date
  updated_at: Date
}

export interface AccessibilitySettings {
  high_contrast: boolean
  large_text: boolean
  dyslexia_font: boolean
  reduced_motion: boolean
  screen_reader: boolean
  focus_indicators: boolean
  color_blind_support: boolean
  sensory_friendly: boolean
  break_reminders: boolean
  focus_timer: boolean
}

export interface CreateUserRequest {
  email: string
  username: string
  password: string
  first_name: string
  last_name: string
  date_of_birth?: string
  neurodiversity_type?: string[]
  parent_email?: string
}

export interface UpdateUserRequest {
  first_name?: string
  last_name?: string
  neurodiversity_type?: string[]
  accessibility_settings?: Partial<AccessibilitySettings>
}

export interface UserResponse {
  id: string
  email: string
  username: string
  first_name: string
  last_name: string
  date_of_birth?: Date
  neurodiversity_type?: string[]
  accessibility_settings?: AccessibilitySettings
  is_active: boolean
  created_at: Date
}

// Default accessibility settings
export const defaultAccessibilitySettings: AccessibilitySettings = {
  high_contrast: false,
  large_text: false,
  dyslexia_font: false,
  reduced_motion: false,
  screen_reader: false,
  focus_indicators: true,
  color_blind_support: false,
  sensory_friendly: false,
  break_reminders: true,
  focus_timer: false
}
"@
            "backend/src/middleware/errorHandler.ts" = @"
import { Request, Response, NextFunction } from 'express'

export interface AppError extends Error {
  statusCode?: number
  isOperational?: boolean
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Default error values
  let statusCode = err.statusCode || 500
  let message = err.message || 'Internal Server Error'
  
  // Log error details
  console.error('🚨 Error occurred:', {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString()
  })
  
  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400
    message = 'Validation Error'
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401
    message = 'Unauthorized'
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401
    message = 'Invalid token'
  } else if (err.name === 'TokenExpiredError') {
    statusCode = 401
    message = 'Token expired'
  } else if (err.name === 'CastError') {
    statusCode = 400
    message = 'Invalid ID format'
  }
  
  // Don't leak error details in production
  const isDevelopment = process.env.NODE_ENV === 'development'
  
  const errorResponse = {
    error: {
      message,
      status: statusCode,
      ...(isDevelopment && {
        stack: err.stack,
        details: err
      })
    },
    timestamp: new Date().toISOString(),
    path: req.url,
    method: req.method
  }
  
  res.status(statusCode).json(errorResponse)
}

// Create operational error
export const createError = (message: string, statusCode: number = 500): AppError => {
  const error: AppError = new Error(message)
  error.statusCode = statusCode
  error.isOperational = true
  return error
}

// Async error wrapper
export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}
"@
            "frontend/src/App.tsx" = @"
import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { HelmetProvider } from 'react-helmet-async'
import { Toaster } from 'react-hot-toast'

// Contexts
import { AuthProvider } from './contexts/AuthContext'
import { AccessibilityProvider } from './contexts/AccessibilityContext'

// Components
import Header from './components/layout/Header'
import Footer from './components/layout/Footer'
import AccessibilityToolbar from './components/accessibility/AccessibilityToolbar'

// Pages
import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import Dashboard from './pages/Dashboard'
import Games from './pages/Games'
import Profile from './pages/Profile'
import Settings from './pages/Settings'
import ParentDashboard from './pages/ParentDashboard'

// Styles
import './styles/index.css'

const App: React.FC = () => {
  return (
    <HelmetProvider>
      <AccessibilityProvider>
        <AuthProvider>
          <Router>
            <div className="min-h-screen bg-gray-50 dark:bg-gray-900 transition-colors duration-200">
              {/* Accessibility Toolbar */}
              <AccessibilityToolbar />
              
              {/* Main Layout */}
              <div className="flex flex-col min-h-screen">
                {/* Header */}
                <Header />
                
                {/* Main Content */}
                <main className="flex-grow container mx-auto px-4 py-8">
                  <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/login" element={<Login />} />
                    <Route path="/register" element={<Register />} />
                    <Route path="/dashboard" element={<Dashboard />} />
                    <Route path="/games" element={<Games />} />
                    <Route path="/profile" element={<Profile />} />
                    <Route path="/settings" element={<Settings />} />
                    <Route path="/parent-dashboard" element={<ParentDashboard />} />
                  </Routes>
                </main>
                
                {/* Footer */}
                <Footer />
              </div>
              
              {/* Toast Notifications */}
              <Toaster
                position="top-right"
                toastOptions={{
                  duration: 4000,
                  style: {
                    background: '#363636',
                    color: '#fff',
                  },
                  success: {
                    duration: 3000,
                    iconTheme: {
                      primary: '#4ade80',
                      secondary: '#fff',
                    },
                  },
                  error: {
                    duration: 5000,
                    iconTheme: {
                      primary: '#ef4444',
                      secondary: '#fff',
                    },
                  },
                }}
              />
            </div>
          </Router>
        </AuthProvider>
      </AccessibilityProvider>
    </HelmetProvider>
  )
}

export default App
"@
            "frontend/src/main.tsx" = @"
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'

// Ensure the root element exists
const rootElement = document.getElementById('root')
if (!rootElement) {
  throw new Error('Root element not found')
}

// Create React root and render app
const root = ReactDOM.createRoot(rootElement)

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)

// Hot Module Replacement (HMR) for development
if (import.meta.hot) {
  import.meta.hot.accept()
}
"@
            "database/schemas/users.sql" = @"
-- Users table schema for InfiniCoreCipher
-- Stores user account information and accessibility preferences

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Main users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    neurodiversity_type TEXT[], -- Array of neurodiversity types (ADHD, Autism, Dyslexia, etc.)
    parent_email VARCHAR(255), -- For children accounts
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Accessibility settings table
CREATE TABLE IF NOT EXISTS accessibility_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    high_contrast BOOLEAN DEFAULT false,
    large_text BOOLEAN DEFAULT false,
    dyslexia_font BOOLEAN DEFAULT false,
    reduced_motion BOOLEAN DEFAULT false,
    screen_reader BOOLEAN DEFAULT false,
    focus_indicators BOOLEAN DEFAULT true,
    color_blind_support BOOLEAN DEFAULT false,
    sensory_friendly BOOLEAN DEFAULT false,
    break_reminders BOOLEAN DEFAULT true,
    focus_timer BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User sessions table for JWT token management
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_accessibility_settings_user_id ON accessibility_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions(expires_at);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for automatic timestamp updates
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_accessibility_settings_updated_at 
    BEFORE UPDATE ON accessibility_settings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comments for documentation
COMMENT ON TABLE users IS 'Main user accounts table storing authentication and profile information';
COMMENT ON TABLE accessibility_settings IS 'User-specific accessibility preferences and settings';
COMMENT ON TABLE user_sessions IS 'Active user sessions for JWT token management';

COMMENT ON COLUMN users.neurodiversity_type IS 'Array of neurodiversity types: ADHD, Autism, Dyslexia, etc.';
COMMENT ON COLUMN users.parent_email IS 'Parent/guardian email for child accounts';
COMMENT ON COLUMN accessibility_settings.high_contrast IS 'Enable high contrast mode for better visibility';
COMMENT ON COLUMN accessibility_settings.dyslexia_font IS 'Use dyslexia-friendly fonts (OpenDyslexic)';
COMMENT ON COLUMN accessibility_settings.sensory_friendly IS 'Reduce sensory stimuli (animations, sounds)';
"@
        }
        "2" = @{
            "backend/src/controllers/AuthController.ts" = @"
import { Request, Response } from 'express'
import { AuthService } from '../services/AuthService'
import { asyncHandler, createError } from '../middleware/errorHandler'
import { validateEmail, validatePassword } from '../utils/validation'

export class AuthController {
  private authService: AuthService

  constructor() {
    this.authService = new AuthService()
  }

  // Register new user
  register = asyncHandler(async (req: Request, res: Response) => {
    const { email, username, password, first_name, last_name, date_of_birth, neurodiversity_type, parent_email } = req.body

    // Validation
    if (!email || !username || !password || !first_name || !last_name) {
      throw createError('Missing required fields', 400)
    }

    if (!validateEmail(email)) {
      throw createError('Invalid email format', 400)
    }

    if (!validatePassword(password)) {
      throw createError('Password must be at least 8 characters with uppercase, lowercase, number and special character', 400)
    }

    // Check if user already exists
    const existingUser = await this.authService.findUserByEmail(email)
    if (existingUser) {
      throw createError('User with this email already exists', 409)
    }

    const existingUsername = await this.authService.findUserByUsername(username)
    if (existingUsername) {
      throw createError('Username already taken', 409)
    }

    // Create user
    const user = await this.authService.createUser({
      email,
      username,
      password,
      first_name,
      last_name,
      date_of_birth,
      neurodiversity_type,
      parent_email
    })

    // Generate token
    const token = await this.authService.generateToken(user.id)

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        first_name: user.first_name,
        last_name: user.last_name
      },
      token
    })
  })

  // Login user
  login = asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body

    if (!email || !password) {
      throw createError('Email and password are required', 400)
    }

    // Authenticate user
    const user = await this.authService.authenticateUser(email, password)
    if (!user) {
      throw createError('Invalid email or password', 401)
    }

    if (!user.is_active) {
      throw createError('Account is deactivated', 401)
    }

    // Generate token
    const token = await this.authService.generateToken(user.id)

    // Update last login
    await this.authService.updateLastLogin(user.id)

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        first_name: user.first_name,
        last_name: user.last_name,
        accessibility_settings: user.accessibility_settings
      },
      token
    })
  })

  // Logout user
  logout = asyncHandler(async (req: Request, res: Response) => {
    const token = req.headers.authorization?.replace('Bearer ', '')
    
    if (token) {
      await this.authService.invalidateToken(token)
    }

    res.json({ message: 'Logout successful' })
  })

  // Get current user profile
  getProfile = asyncHandler(async (req: Request, res: Response) => {
    const userId = (req as any).user.id

    const user = await this.authService.getUserProfile(userId)
    if (!user) {
      throw createError('User not found', 404)
    }

    res.json({
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        first_name: user.first_name,
        last_name: user.last_name,
        date_of_birth: user.date_of_birth,
        neurodiversity_type: user.neurodiversity_type,
        accessibility_settings: user.accessibility_settings,
        created_at: user.created_at
      }
    })
  })

  // Refresh token
  refreshToken = asyncHandler(async (req: Request, res: Response) => {
    const { refresh_token } = req.body

    if (!refresh_token) {
      throw createError('Refresh token is required', 400)
    }

    const newToken = await this.authService.refreshToken(refresh_token)
    if (!newToken) {
      throw createError('Invalid refresh token', 401)
    }

    res.json({
      message: 'Token refreshed successfully',
      token: newToken
    })
  })

  // Change password
  changePassword = asyncHandler(async (req: Request, res: Response) => {
    const userId = (req as any).user.id
    const { current_password, new_password } = req.body

    if (!current_password || !new_password) {
      throw createError('Current password and new password are required', 400)
    }

    if (!validatePassword(new_password)) {
      throw createError('New password must be at least 8 characters with uppercase, lowercase, number and special character', 400)
    }

    const success = await this.authService.changePassword(userId, current_password, new_password)
    if (!success) {
      throw createError('Current password is incorrect', 400)
    }

    res.json({ message: 'Password changed successfully' })
  })
}
"@
            "backend/src/services/AuthService.ts" = @"
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { pool } from '../config/database'
import { User, CreateUserRequest, defaultAccessibilitySettings } from '../models/User'

export class AuthService {
  private jwtSecret: string
  private jwtExpiresIn: string

  constructor() {
    this.jwtSecret = process.env.JWT_SECRET || 'your-super-secret-jwt-key'
    this.jwtExpiresIn = process.env.JWT_EXPIRES_IN || '7d'
  }

  // Create new user
  async createUser(userData: CreateUserRequest): Promise<User> {
    const client = await pool.connect()
    
    try {
      await client.query('BEGIN')

      // Hash password
      const saltRounds = 12
      const password_hash = await bcrypt.hash(userData.password, saltRounds)

      // Insert user
      const userQuery = `
        INSERT INTO users (email, username, password_hash, first_name, last_name, date_of_birth, neurodiversity_type, parent_email)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id, email, username, first_name, last_name, date_of_birth, neurodiversity_type, parent_email, is_active, created_at, updated_at
      `
      
      const userResult = await client.query(userQuery, [
        userData.email,
        userData.username,
        password_hash,
        userData.first_name,
        userData.last_name,
        userData.date_of_birth || null,
        userData.neurodiversity_type || null,
        userData.parent_email || null
      ])

      const user = userResult.rows[0]

      // Create default accessibility settings
      const accessibilityQuery = `
        INSERT INTO accessibility_settings (user_id, high_contrast, large_text, dyslexia_font, reduced_motion, screen_reader, focus_indicators, color_blind_support, sensory_friendly, break_reminders, focus_timer)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *
      `

      await client.query(accessibilityQuery, [
        user.id,
        defaultAccessibilitySettings.high_contrast,
        defaultAccessibilitySettings.large_text,
        defaultAccessibilitySettings.dyslexia_font,
        defaultAccessibilitySettings.reduced_motion,
        defaultAccessibilitySettings.screen_reader,
        defaultAccessibilitySettings.focus_indicators,
        defaultAccessibilitySettings.color_blind_support,
        defaultAccessibilitySettings.sensory_friendly,
        defaultAccessibilitySettings.break_reminders,
        defaultAccessibilitySettings.focus_timer
      ])

      await client.query('COMMIT')
      return user
      
    } catch (error) {
      await client.query('ROLLBACK')
      throw error
    } finally {
      client.release()
    }
  }

  // Find user by email
  async findUserByEmail(email: string): Promise<User | null> {
    const query = `
      SELECT u.*, a.* 
      FROM users u
      LEFT JOIN accessibility_settings a ON u.id = a.user_id
      WHERE u.email = $1
    `
    
    const result = await pool.query(query, [email])
    
    if (result.rows.length === 0) {
      return null
    }

    const row = result.rows[0]
    return this.mapRowToUser(row)
  }

  // Find user by username
  async findUserByUsername(username: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE username = $1'
    const result = await pool.query(query, [username])
    
    return result.rows.length > 0 ? result.rows[0] : null
  }

  // Authenticate user
  async authenticateUser(email: string, password: string): Promise<User | null> {
    const user = await this.findUserByEmail(email)
    
    if (!user) {
      return null
    }

    const isValidPassword = await bcrypt.compare(password, user.password_hash)
    
    return isValidPassword ? user : null
  }

  // Generate JWT token
  async generateToken(userId: string): Promise<string> {
    const payload = {
      userId,
      iat: Math.floor(Date.now() / 1000)
    }

    const token = jwt.sign(payload, this.jwtSecret, { expiresIn: this.jwtExpiresIn })

    // Store session in database
    const sessionQuery = `
      INSERT INTO user_sessions (user_id, token_hash, expires_at)
      VALUES ($1, $2, $3)
    `
    
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
    const tokenHash = await bcrypt.hash(token, 10)
    
    await pool.query(sessionQuery, [userId, tokenHash, expiresAt])

    return token
  }

  // Verify JWT token
  async verifyToken(token: string): Promise<any> {
    try {
      const decoded = jwt.verify(token, this.jwtSecret)
      
      // Check if session exists and is valid
      const sessionQuery = `
        SELECT * FROM user_sessions 
        WHERE user_id = $1 AND expires_at > NOW()
      `
      
      const sessionResult = await pool.query(sessionQuery, [(decoded as any).userId])
      
      if (sessionResult.rows.length === 0) {
        return null
      }

      return decoded
    } catch (error) {
      return null
    }
  }

  // Get user profile
  async getUserProfile(userId: string): Promise<User | null> {
    const query = `
      SELECT u.*, a.* 
      FROM users u
      LEFT JOIN accessibility_settings a ON u.id = a.user_id
      WHERE u.id = $1
    `
    
    const result = await pool.query(query, [userId])
    
    if (result.rows.length === 0) {
      return null
    }

    return this.mapRowToUser(result.rows[0])
  }

  // Update last login
  async updateLastLogin(userId: string): Promise<void> {
    const query = 'UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = $1'
    await pool.query(query, [userId])
  }

  // Invalidate token
  async invalidateToken(token: string): Promise<void> {
    try {
      const decoded = jwt.verify(token, this.jwtSecret) as any
      
      const query = 'DELETE FROM user_sessions WHERE user_id = $1'
      await pool.query(query, [decoded.userId])
    } catch (error) {
      // Token is invalid, nothing to do
    }
  }

  // Change password
  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<boolean> {
    const user = await this.getUserProfile(userId)
    
    if (!user) {
      return false
    }

    const isValidPassword = await bcrypt.compare(currentPassword, user.password_hash)
    
    if (!isValidPassword) {
      return false
    }

    const newPasswordHash = await bcrypt.hash(newPassword, 12)
    
    const query = 'UPDATE users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2'
    await pool.query(query, [newPasswordHash, userId])

    return true
  }

  // Refresh token
  async refreshToken(refreshToken: string): Promise<string | null> {
    try {
      const decoded = jwt.verify(refreshToken, this.jwtSecret) as any
      return await this.generateToken(decoded.userId)
    } catch (error) {
      return null
    }
  }

  // Helper method to map database row to User object
  private mapRowToUser(row: any): User {
    return {
      id: row.id,
      email: row.email,
      username: row.username,
      password_hash: row.password_hash,
      first_name: row.first_name,
      last_name: row.last_name,
      date_of_birth: row.date_of_birth,
      neurodiversity_type: row.neurodiversity_type,
      accessibility_settings: {
        high_contrast: row.high_contrast || false,
        large_text: row.large_text || false,
        dyslexia_font: row.dyslexia_font || false,
        reduced_motion: row.reduced_motion || false,
        screen_reader: row.screen_reader || false,
        focus_indicators: row.focus_indicators || true,
        color_blind_support: row.color_blind_support || false,
        sensory_friendly: row.sensory_friendly || false,
        break_reminders: row.break_reminders || true,
        focus_timer: row.focus_timer || false
      },
      parent_email: row.parent_email,
      is_active: row.is_active,
      created_at: row.created_at,
      updated_at: row.updated_at
    }
  }
}
"@
        }
    }
    
    # Sprawdź którą fazę generować
    if (-not $ComponentTemplates.ContainsKey($Phase)) {
        Write-Host "❌ Nieznana faza: $Phase" -ForegroundColor $Red
        Write-Host "Dostępne fazy: $($ComponentTemplates.Keys -join ', ')" -ForegroundColor $Yellow
        exit 1
    }
    
    $PhaseComponents = $ComponentTemplates[$Phase]
    Write-Host "🎯 GENEROWANIE KOMPONENTÓW FAZY $Phase" -ForegroundColor $Cyan
    Write-Host "Liczba komponentów: $($PhaseComponents.Count)" -ForegroundColor $Yellow
    Write-Host ""
    
    $CreatedFiles = 0
    $SkippedFiles = 0
    $ErrorFiles = 0
    
    foreach ($FilePath in $PhaseComponents.Keys) {
        $Content = $PhaseComponents[$FilePath]
        
        Write-Host "📄 Przetwarzanie: $FilePath" -ForegroundColor $Yellow
        
        if ($DryRun) {
            Write-Host "   🔍 DRY RUN - plik zostałby utworzony" -ForegroundColor $Cyan
            $CreatedFiles++
            continue
        }
        
        # Sprawdź czy plik już istnieje
        if ((Test-Path $FilePath) -and (-not $Force)) {
            Write-Host "   ⏭️  Plik już istnieje (użyj -Force aby nadpisać)" -ForegroundColor $Yellow
            $SkippedFiles++
            continue
        }
        
        try {
            # Utwórz folder jeśli nie istnieje
            $Directory = Split-Path $FilePath -Parent
            if ($Directory -and (-not (Test-Path $Directory))) {
                New-Item -ItemType Directory -Path $Directory -Force | Out-Null
                Write-Host "   📁 Utworzono folder: $Directory" -ForegroundColor $Green
            }
            
            # Utwórz plik
            $Content | Out-File -FilePath $FilePath -Encoding UTF8
            Write-Host "   ✅ Utworzono plik" -ForegroundColor $Green
            $CreatedFiles++
            
        } catch {
            Write-Host "   ❌ Błąd: $($_.Exception.Message)" -ForegroundColor $Red
            $ErrorFiles++
        }
    }
    
    Write-Host ""
    Write-Host "📊 PODSUMOWANIE GENEROWANIA FAZY $Phase" -ForegroundColor $Cyan
    Write-Host "======================================" -ForegroundColor $Cyan
    Write-Host "✅ Utworzone pliki: $CreatedFiles" -ForegroundColor $Green
    Write-Host "⏭️  Pominięte pliki: $SkippedFiles" -ForegroundColor $Yellow
    Write-Host "❌ Błędy: $ErrorFiles" -ForegroundColor $Red
    
    if ($CreatedFiles -gt 0 -and -not $DryRun) {
        Write-Host ""
        Write-Host "🎉 FAZA $Phase WYGENEROWANA POMYŚLNIE!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "🚀 NASTĘPNE KROKI:" -ForegroundColor $Cyan
        
        if ($Phase -eq "1") {
            Write-Host "1. Skonfiguruj zmienne środowiskowe (.env)" -ForegroundColor $Yellow
            Write-Host "2. Uruchom migracje bazy danych" -ForegroundColor $Yellow
            Write-Host "3. Przetestuj podstawową infrastrukturę" -ForegroundColor $Yellow
            Write-Host "4. Przejdź do fazy 2: .\Generate-Missing-Components.ps1 -Phase 2" -ForegroundColor $Yellow
        } elseif ($Phase -eq "2") {
            Write-Host "1. Przetestuj system autentykacji" -ForegroundColor $Yellow
            Write-Host "2. Sprawdź JWT token generation" -ForegroundColor $Yellow
            Write-Host "3. Przetestuj rejestrację i logowanie" -ForegroundColor $Yellow
            Write-Host "4. Przejdź do fazy 3 (UI komponenty)" -ForegroundColor $Yellow
        }
        
        Write-Host ""
        Write-Host "🧪 TEST KOMPONENTÓW:" -ForegroundColor $Cyan
        Write-Host "npm run dev" -ForegroundColor $Green
    }
    
    if ($DryRun) {
        Write-Host ""
        Write-Host "💡 To był DRY RUN - żadne pliki nie zostały utworzone" -ForegroundColor $Yellow
        Write-Host "Uruchom bez -DryRun aby rzeczywiście utworzyć pliki" -ForegroundColor $Yellow
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONIEC GENEROWANIA KOMPONENTÓW ===" -ForegroundColor $Cyan
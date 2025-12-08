# ClinixAI - Build Flutter Web for Production (Windows)
# This script builds the Flutter web app for deployment to Netlify

Write-Host "🏥 ClinixAI - Building Flutter Web..." -ForegroundColor Cyan
Write-Host ""

# Navigate to Flutter app directory
Set-Location -Path "clinix_app"

# Switch to web-compatible pubspec (removes FFI packages like cactus, isar)
Write-Host "📋 Switching to web-compatible dependencies..." -ForegroundColor Yellow
Copy-Item pubspec_web.yaml pubspec.yaml -Force

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build for web
Write-Host "🔨 Building web app..." -ForegroundColor Yellow
flutter build web --release -t lib/main_web.dart

# Restore native pubspec for local development
Write-Host "🔄 Restoring native pubspec..." -ForegroundColor Yellow
Copy-Item pubspec_native.yaml pubspec.yaml -Force
flutter pub get

# Build info
Write-Host ""
Write-Host "✅ Build complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Output: clinix_app/build/web" -ForegroundColor White
Write-Host ""
Write-Host "🚀 To deploy to Netlify:" -ForegroundColor Cyan
Write-Host "   1. Push to GitHub"
Write-Host "   2. Connect repo to Netlify"
Write-Host "   3. Netlify will auto-build using netlify.toml"
Write-Host ""
Write-Host "⚠️  Note: Users must run 'docker-compose up -d' locally for the backend." -ForegroundColor Yellow

# Return to root
Set-Location -Path ".."

#!/bin/bash
# ClinixAI - Build Flutter Web for Production
# This script builds the Flutter web app for deployment to Netlify

set -e

echo "🏥 ClinixAI - Building Flutter Web..."
echo ""

# Navigate to Flutter app directory
cd clinix_app

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web with HTML renderer (better compatibility)
echo "🔨 Building web app..."
flutter build web --release --web-renderer html

# Build info
echo ""
echo "✅ Build complete!"
echo ""
echo "📁 Output: clinix_app/build/web"
echo ""
echo "🚀 To deploy to Netlify:"
echo "   1. Connect your GitHub repo to Netlify"
echo "   2. Set build command: cd clinix_app && flutter build web --release --web-renderer html"
echo "   3. Set publish directory: clinix_app/build/web"
echo ""
echo "⚠️  Note: Users must run 'docker-compose up -d' locally for the backend."

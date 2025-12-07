/// ClinixAI Configuration
/// 
/// This file contains all configurable settings for the app.
/// For local development: Backend services run on localhost via Docker
/// For Netlify demo: Users must run Docker locally, web app connects to localhost

class AppConfig {
  // Backend service URLs - these point to local Docker services
  // Users must run `docker-compose up` to start the backend
  
  /// Triage Service URL (FastAPI + LangGraph + GraphRAG)
  /// Handles /chat, /analyze, /health endpoints
  static const String triageServiceUrl = 'http://localhost:8000';
  
  /// llama.cpp Server URL (OpenAI-compatible API)
  /// Direct LLM access if needed
  static const String llamaCppUrl = 'http://localhost:8091';
  
  /// API Gateway URL (Node.js)
  /// Optional - for session management
  static const String apiGatewayUrl = 'http://localhost:3000';
  
  /// Neo4j Browser URL
  /// For debugging GraphRAG knowledge base
  static const String neo4jBrowserUrl = 'http://localhost:7475';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 120); // AI responses can be slow
  
  // App Info
  static const String appName = 'ClinixAI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-Powered Emergency Triage for Africa';
  
  // Feature Flags
  static const bool enableGraphRAG = true;  // Use medical knowledge graph
  static const bool enableDebugMode = false; // Show debug info in UI
  
  // Demo Mode Message
  static const String demoModeMessage = '''
🏥 ClinixAI Demo Mode

This web app requires local backend services running via Docker.

To run the demo:
1. Clone the repository
2. Run: docker-compose up -d
3. Wait for services to start (~30 seconds)
4. Refresh this page

Services needed:
• Triage Service (port 8000) - AI reasoning engine
• llama.cpp (port 8091) - Local LLM
• Neo4j (port 7475) - Medical knowledge graph
''';
}

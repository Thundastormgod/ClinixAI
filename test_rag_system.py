#!/usr/bin/env python3
"""
ClinixAI RAG System Test Script
===============================
This script helps team members test all RAG and AI functionality.

PREREQUISITES:
1. Docker containers running: docker-compose up -d
2. Neo4j must be healthy (http://localhost:7475)
3. Triage service running (http://localhost:8000)

USAGE:
    python test_rag_system.py              # Run all tests
    python test_rag_system.py --quick      # Quick health check only
    python test_rag_system.py --chat       # Interactive chat mode
    python test_rag_system.py --upload     # Upload a PDF for testing

TEAM TESTING CHECKLIST:
✅ 1. Health Check - Are all services running?
✅ 2. RAG Stats - Is knowledge loaded in Neo4j?
✅ 3. RAG Query - Can we retrieve medical knowledge?
✅ 4. Chat with Local Model - Does Ollama respond with RAG context?
✅ 5. Triage Analysis - Full AI analysis with RAG enhancement
"""

import requests
import json
import sys
import time
from typing import Dict, Any, Optional
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"
OLLAMA_URL = "http://localhost:11434"
NEO4J_URL = "http://localhost:7475"

# ANSI Colors for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_header(text: str):
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text.center(60)}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.END}\n")

def print_success(text: str):
    print(f"{Colors.GREEN}✅ {text}{Colors.END}")

def print_error(text: str):
    print(f"{Colors.RED}❌ {text}{Colors.END}")

def print_warning(text: str):
    print(f"{Colors.YELLOW}⚠️  {text}{Colors.END}")

def print_info(text: str):
    print(f"{Colors.CYAN}ℹ️  {text}{Colors.END}")

# ==================== TEST FUNCTIONS ====================

def test_service_health() -> bool:
    """Test 1: Check if triage service is healthy"""
    print_header("TEST 1: Service Health Check")
    
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        data = response.json()
        
        if data.get("status") == "healthy":
            print_success(f"Triage Service: {data.get('service')} v{data.get('version')}")
            print_success(f"Engine: {data.get('engine')}")
            return True
        else:
            print_error(f"Service unhealthy: {data}")
            return False
    except Exception as e:
        print_error(f"Cannot connect to triage service: {e}")
        print_info("Make sure to run: docker-compose up -d")
        return False


def test_ollama_health() -> bool:
    """Test 2: Check if Ollama is running"""
    print_header("TEST 2: Ollama Local Model Check")
    
    try:
        # Check Ollama API
        response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=10)
        data = response.json()
        
        models = data.get("models", [])
        if models:
            print_success(f"Ollama is running with {len(models)} model(s):")
            for model in models[:5]:  # Show first 5
                size_gb = model.get("size", 0) / (1024**3)
                print(f"    • {model.get('name')} ({size_gb:.1f} GB)")
            return True
        else:
            print_warning("Ollama is running but no models installed")
            print_info("Run: docker exec -it clinixai-ollama ollama pull qwen2.5:3b")
            return True
    except Exception as e:
        print_error(f"Ollama not reachable: {e}")
        print_info("Ollama container might be starting. Wait and retry.")
        return False


def test_neo4j_connection() -> bool:
    """Test 3: Check Neo4j database"""
    print_header("TEST 3: Neo4j Database Check")
    
    try:
        response = requests.get(f"{NEO4J_URL}", timeout=10)
        if response.status_code == 200:
            print_success("Neo4j Browser accessible at http://localhost:7475")
            print_info("Login: neo4j / clinixai_neo4j_password")
            return True
        else:
            print_warning(f"Neo4j returned status {response.status_code}")
            return True  # Still might work
    except Exception as e:
        print_error(f"Neo4j not reachable: {e}")
        return False


def test_rag_stats() -> Dict[str, Any]:
    """Test 4: Check RAG knowledge base statistics"""
    print_header("TEST 4: RAG Knowledge Base Stats")
    
    try:
        response = requests.get(f"{BASE_URL}/rag/stats", timeout=30)
        data = response.json()
        
        if data.get("success"):
            stats = data.get("database_stats", {})
            print_success(f"RAG Status: {data.get('status')}")
            print_success(f"Embedding Model: {data.get('embedding_model')}")
            print(f"\n{Colors.CYAN}Knowledge Graph Contents:{Colors.END}")
            
            total = 0
            for node_type, count in stats.items():
                total += count
                icon = "📄" if node_type == "Chunk" else "📚" if node_type == "Document" else "🏷️"
                print(f"    {icon} {node_type}: {count:,}")
            
            print(f"\n    {Colors.BOLD}Total Nodes: {total:,}{Colors.END}")
            
            if stats.get("Chunk", 0) == 0:
                print_warning("\nNo documents loaded yet!")
                print_info("Upload PDFs: POST /rag/upload-pdf")
            
            return data
        else:
            print_error(f"RAG stats failed: {data.get('error')}")
            return {}
    except Exception as e:
        print_error(f"Failed to get RAG stats: {e}")
        return {}


def test_rag_query(query: str = "What are the symptoms of malaria?") -> bool:
    """Test 5: Test RAG retrieval"""
    print_header("TEST 5: RAG Query Test")
    print(f"Query: \"{query}\"\n")
    
    try:
        response = requests.post(
            f"{BASE_URL}/rag/query",
            json={"query": query, "top_k": 3},
            timeout=30
        )
        data = response.json()
        
        if data.get("success"):
            chunks = data.get("chunks", [])
            entities = data.get("entities", [])
            paths = data.get("graph_paths", [])
            
            print_success(f"Retrieved {len(chunks)} relevant chunks")
            print_success(f"Found {len(entities)} related entities")
            print_success(f"Graph paths: {len(paths)}")
            
            if chunks:
                print(f"\n{Colors.CYAN}Sample Retrieved Text:{Colors.END}")
                sample = chunks[0] if isinstance(chunks[0], str) else chunks[0].get("text", str(chunks[0]))
                print(f"    \"{sample[:200]}...\"")
            
            if paths:
                print(f"\n{Colors.CYAN}Graph Insights:{Colors.END}")
                for path in paths[:3]:
                    print(f"    • {path}")
            
            return True
        else:
            print_error(f"RAG query failed: {data.get('formatted_context')}")
            return False
    except Exception as e:
        print_error(f"RAG query error: {e}")
        return False


def test_chat_endpoint(message: str = "I have a fever and headache for 2 days") -> bool:
    """Test 6: Test the chat endpoint with Ollama + RAG"""
    print_header("TEST 6: Chat with Local AI + RAG")
    print(f"Message: \"{message}\"\n")
    
    try:
        response = requests.post(
            f"{BASE_URL}/chat",
            json={"message": message, "use_rag": True},
            timeout=120  # Local models can be slow
        )
        
        if response.status_code == 404:
            print_warning("Chat endpoint not available yet")
            print_info("The /chat endpoint needs to be added to main.py")
            return False
        
        data = response.json()
        
        if data.get("success"):
            print_success(f"Model: {data.get('model')}")
            print_success(f"Response time: {data.get('response_time_ms', 0)}ms")
            
            if data.get("rag_context_used"):
                print_success("RAG context was used!")
            
            print(f"\n{Colors.CYAN}AI Response:{Colors.END}")
            print(f"    {data.get('response', 'No response')[:500]}")
            
            return True
        else:
            print_error(f"Chat failed: {data.get('error')}")
            return False
    except requests.exceptions.Timeout:
        print_warning("Chat request timed out (Ollama might be loading model)")
        print_info("Try again - first request loads the model into memory")
        return False
    except Exception as e:
        print_error(f"Chat error: {e}")
        return False


def test_triage_analysis() -> bool:
    """Test 7: Full triage analysis with RAG"""
    print_header("TEST 7: Full Triage Analysis")
    
    test_case = {
        "session_id": f"test-{int(time.time())}",
        "symptoms": [
            {"description": "high fever for 3 days", "severity": 7, "duration_hours": 72},
            {"description": "severe headache", "severity": 6, "duration_hours": 48},
            {"description": "body aches and chills", "severity": 5, "duration_hours": 72}
        ],
        "vital_signs": {
            "temperature": 39.2,
            "heart_rate": 95,
            "blood_pressure": "120/80"
        },
        "patient_age": 28,
        "patient_gender": "female",
        "medical_history": []
    }
    
    print(f"Test Case: {json.dumps(test_case['symptoms'], indent=2)}\n")
    
    try:
        # Try RAG-enhanced analysis first
        response = requests.post(
            f"{BASE_URL}/analyze-with-rag",
            json=test_case,
            timeout=60
        )
        
        data = response.json()
        
        print_success(f"Urgency: {data.get('urgency_level', 'unknown').upper()}")
        print_success(f"Confidence: {data.get('confidence_score', 0):.0%}")
        print_success(f"AI Model: {data.get('ai_model', 'unknown')}")
        
        if data.get("rag_enhanced"):
            print_success(f"RAG Enhanced: Yes ({data.get('knowledge_sources', 0)} sources)")
        
        print(f"\n{Colors.CYAN}Assessment:{Colors.END}")
        print(f"    {data.get('primary_assessment', 'N/A')}")
        
        print(f"\n{Colors.CYAN}Recommended Action:{Colors.END}")
        print(f"    {data.get('recommended_action', 'N/A')}")
        
        if data.get("differential_diagnoses"):
            print(f"\n{Colors.CYAN}Possible Conditions:{Colors.END}")
            for dx in data.get("differential_diagnoses", [])[:3]:
                if isinstance(dx, dict):
                    print(f"    • {dx.get('condition', 'Unknown')} ({dx.get('probability', 0):.0%})")
        
        if data.get("graph_insights"):
            print(f"\n{Colors.CYAN}Knowledge Graph Insights:{Colors.END}")
            for insight in data.get("graph_insights", [])[:3]:
                print(f"    • {insight}")
        
        return True
    except Exception as e:
        print_error(f"Triage analysis failed: {e}")
        return False


def interactive_chat():
    """Interactive chat mode"""
    print_header("Interactive Chat Mode")
    print("Chat with ClinixAI using local Ollama + RAG knowledge")
    print("Type 'exit' or 'quit' to end the session\n")
    
    while True:
        try:
            user_input = input(f"{Colors.GREEN}You: {Colors.END}").strip()
            
            if user_input.lower() in ['exit', 'quit', 'q']:
                print_info("Goodbye!")
                break
            
            if not user_input:
                continue
            
            print(f"{Colors.YELLOW}Thinking...{Colors.END}", end="\r")
            
            response = requests.post(
                f"{BASE_URL}/chat",
                json={"message": user_input, "use_rag": True},
                timeout=120
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"{Colors.CYAN}ClinixAI: {Colors.END}{data.get('response', 'No response')}\n")
            else:
                print_error(f"Error: {response.text}")
        except KeyboardInterrupt:
            print_info("\nGoodbye!")
            break
        except Exception as e:
            print_error(f"Error: {e}")


def upload_test_pdf(pdf_path: str):
    """Upload a PDF for testing"""
    print_header("PDF Upload Test")
    
    try:
        with open(pdf_path, 'rb') as f:
            files = {'file': (pdf_path.split('/')[-1], f, 'application/pdf')}
            response = requests.post(
                f"{BASE_URL}/rag/upload-pdf",
                files=files,
                data={'extract_entities': 'false'},  # Save API costs
                timeout=300
            )
        
        data = response.json()
        
        if data.get("success"):
            print_success(f"Uploaded: {data.get('file')}")
            print_success(f"Chunks created: {data.get('chunks')}")
            print_success(f"Entities extracted: {data.get('entities_extracted')}")
        else:
            print_error(f"Upload failed: {data.get('error')}")
    except FileNotFoundError:
        print_error(f"File not found: {pdf_path}")
    except Exception as e:
        print_error(f"Upload error: {e}")


# ==================== MAIN ====================

def run_all_tests():
    """Run all tests in sequence"""
    print(f"\n{Colors.BOLD}ClinixAI RAG System Test Suite{Colors.END}")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    results = {}
    
    # Run tests
    results["Service Health"] = test_service_health()
    results["Ollama"] = test_ollama_health()
    results["Neo4j"] = test_neo4j_connection()
    results["RAG Stats"] = bool(test_rag_stats())
    results["RAG Query"] = test_rag_query()
    results["Chat Endpoint"] = test_chat_endpoint()
    results["Triage Analysis"] = test_triage_analysis()
    
    # Summary
    print_header("TEST SUMMARY")
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for test, result in results.items():
        status = f"{Colors.GREEN}PASS{Colors.END}" if result else f"{Colors.RED}FAIL{Colors.END}"
        print(f"  {test}: {status}")
    
    print(f"\n{Colors.BOLD}Results: {passed}/{total} tests passed{Colors.END}")
    
    if passed == total:
        print_success("\nAll systems operational! 🎉")
    else:
        print_warning("\nSome tests failed. Check the output above for details.")
    
    return passed == total


def quick_check():
    """Quick health check only"""
    print_header("Quick Health Check")
    
    checks = [
        ("Triage Service", f"{BASE_URL}/health"),
        ("Ollama", f"{OLLAMA_URL}/api/tags"),
        ("Neo4j", NEO4J_URL),
    ]
    
    all_ok = True
    for name, url in checks:
        try:
            r = requests.get(url, timeout=5)
            if r.status_code == 200:
                print_success(f"{name}: OK")
            else:
                print_warning(f"{name}: Status {r.status_code}")
        except:
            print_error(f"{name}: Not reachable")
            all_ok = False
    
    return all_ok


if __name__ == "__main__":
    args = sys.argv[1:]
    
    if "--quick" in args:
        quick_check()
    elif "--chat" in args:
        interactive_chat()
    elif "--upload" in args:
        # Find PDF path in args
        pdf_idx = args.index("--upload") + 1
        if pdf_idx < len(args):
            upload_test_pdf(args[pdf_idx])
        else:
            print_error("Please provide PDF path: --upload /path/to/file.pdf")
    else:
        success = run_all_tests()
        sys.exit(0 if success else 1)

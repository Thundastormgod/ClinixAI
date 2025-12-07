# Download GGUF model for llama.cpp server (Windows PowerShell)
# Run: .\download_model.ps1

Write-Host "=== ClinixAI Model Downloader ===" -ForegroundColor Cyan
Write-Host ""

# Create models directory
$modelsDir = "models\gguf"
if (-not (Test-Path $modelsDir)) {
    New-Item -ItemType Directory -Path $modelsDir -Force | Out-Null
    Write-Host "Created directory: $modelsDir" -ForegroundColor Green
}

# Model options
Write-Host "Available models:" -ForegroundColor Yellow
Write-Host "  1. Qwen2.5-3B-Instruct (Q4_K_M) - 2GB, fast, good quality [RECOMMENDED]"
Write-Host "  2. Qwen2.5-1.5B-Instruct (Q4_K_M) - 1GB, very fast, lighter"
Write-Host "  3. Phi-3-mini-4k-instruct (Q4_K_M) - 2.3GB, Microsoft model"
Write-Host ""

$choice = Read-Host "Select model (1-3, default=1)"
if ([string]::IsNullOrEmpty($choice)) { $choice = "1" }

switch ($choice) {
    "1" {
        $modelName = "qwen2.5-3b-instruct-q4_k_m.gguf"
        $modelUrl = "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"
        $modelSize = "~2GB"
    }
    "2" {
        $modelName = "qwen2.5-1.5b-instruct-q4_k_m.gguf"
        $modelUrl = "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf"
        $modelSize = "~1GB"
    }
    "3" {
        $modelName = "Phi-3-mini-4k-instruct-q4.gguf"
        $modelUrl = "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
        $modelSize = "~2.3GB"
    }
    default {
        Write-Host "Invalid choice, using default (Qwen2.5-3B)" -ForegroundColor Yellow
        $modelName = "qwen2.5-3b-instruct-q4_k_m.gguf"
        $modelUrl = "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"
        $modelSize = "~2GB"
    }
}

$outputPath = Join-Path $modelsDir $modelName

Write-Host ""
Write-Host "Downloading $modelName ($modelSize)..." -ForegroundColor Cyan
Write-Host "URL: $modelUrl" -ForegroundColor Gray
Write-Host "This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

try {
    # Use BITS for better download handling
    $ProgressPreference = 'SilentlyContinue'  # Speeds up download
    Invoke-WebRequest -Uri $modelUrl -OutFile $outputPath -UseBasicParsing
    
    Write-Host "Download complete!" -ForegroundColor Green
    Write-Host "Model saved to: $outputPath" -ForegroundColor Green
    
    # Get file size
    $fileSize = (Get-Item $outputPath).Length / 1GB
    Write-Host "File size: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Gray
}
catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try manual download:" -ForegroundColor Yellow
    Write-Host "  1. Go to: $modelUrl"
    Write-Host "  2. Save to: $outputPath"
    exit 1
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Option 1: Run llama.cpp with Docker (standalone):" -ForegroundColor Yellow
Write-Host "  docker run -d -p 8091:8080 -v `"$(Get-Location)/models/gguf:/models`" ghcr.io/ggerganov/llama.cpp:server --model /models/$modelName --ctx-size 2048 --threads 4 --host 0.0.0.0"
Write-Host ""
Write-Host "Option 2: Update docker-compose.yml to use this model:" -ForegroundColor Yellow
Write-Host "  Edit the llama-cpp service command to use: /models/$modelName"
Write-Host ""
Write-Host "Option 3: Test the API:" -ForegroundColor Yellow
Write-Host '  curl http://localhost:8091/v1/chat/completions -d ''{"messages":[{"role":"user","content":"Hello"}]}'''

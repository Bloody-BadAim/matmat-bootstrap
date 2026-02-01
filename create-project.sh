#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║     🚀 matmat.me Project Creator      ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Get project info
read -p "Project name: " PROJECT_NAME
read -p "Project type (nextjs/python/node): " PROJECT_TYPE
read -p "GitHub repo (owner/name, leave empty to skip): " GITHUB_REPO

# Validate
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    exit 1
fi

PROJECT_DIR="$HOME/projects/$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Directory $PROJECT_DIR already exists${NC}"
    exit 1
fi

echo -e "${GREEN}Creating project: $PROJECT_NAME${NC}"

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize git
git init
echo -e "${GREEN}✓ Git initialized${NC}"

# Create base files
cat > .gitignore << 'GITIGNORE'
# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Build
dist/
build/
*.egg-info/

# Logs
*.log
npm-debug.log*

# Coverage
coverage/
.coverage
htmlcov/
GITIGNORE

cat > .editorconfig << 'EDITORCONFIG'
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false
EDITORCONFIG

cat > README.md << README
# $PROJECT_NAME

Created with [matmat-bootstrap](https://github.com/Bloody-BadAim/matmat-bootstrap)

## Getting Started

\`\`\`bash
# Install dependencies
npm install  # or: pip install -r requirements.txt

# Start development
npm run dev  # or: python main.py
\`\`\`

## Scripts

- \`npm run dev\` - Start development server
- \`npm run build\` - Build for production
- \`npm run test\` - Run tests
- \`npm run lint\` - Lint code
README

echo -e "${GREEN}✓ Base files created${NC}"

# Project type specific setup
case $PROJECT_TYPE in
    nextjs)
        echo -e "${BLUE}Setting up Next.js project...${NC}"
        npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm
        ;;
    python)
        echo -e "${BLUE}Setting up Python project...${NC}"
        python3 -m venv venv
        cat > requirements.txt << 'REQS'
fastapi>=0.109.0
uvicorn>=0.27.0
python-dotenv>=1.0.0
pytest>=8.0.0
black>=24.1.0
ruff>=0.1.14
REQS
        cat > main.py << 'MAIN'
from fastapi import FastAPI

app = FastAPI(title="$PROJECT_NAME")

@app.get("/")
def read_root():
    return {"message": "Hello from $PROJECT_NAME!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
MAIN
        echo -e "${YELLOW}Run: source venv/bin/activate && pip install -r requirements.txt${NC}"
        ;;
    node)
        echo -e "${BLUE}Setting up Node.js project...${NC}"
        npm init -y
        npm install express dotenv
        npm install -D typescript @types/node @types/express ts-node nodemon eslint prettier
        mkdir -p src
        cat > src/index.ts << 'INDEX'
import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from $PROJECT_NAME!' });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
INDEX
        ;;
    *)
        echo -e "${YELLOW}No template selected, basic setup only${NC}"
        ;;
esac

# Create devcontainer
mkdir -p .devcontainer
cat > .devcontainer/devcontainer.json << 'DEVCONTAINER'
{
  "name": "$PROJECT_NAME",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:20",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "github.copilot"
      ]
    }
  },
  "postCreateCommand": "npm install",
  "forwardPorts": [3000]
}
DEVCONTAINER

echo -e "${GREEN}✓ Devcontainer created${NC}"

# Setup GitHub repo if provided
if [ -n "$GITHUB_REPO" ]; then
    echo -e "${BLUE}Setting up GitHub remote...${NC}"
    git remote add origin "git@github.com:$GITHUB_REPO.git"
    echo -e "${GREEN}✓ GitHub remote added${NC}"
fi

# Initial commit
git add .
git commit -m "🎉 Initial commit - created with matmat-bootstrap"

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════╗"
echo "║     ✅ Project created successfully!   ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "Location: ${BLUE}$PROJECT_DIR${NC}"
echo -e "Next steps:"
echo -e "  cd $PROJECT_DIR"
echo -e "  code ."

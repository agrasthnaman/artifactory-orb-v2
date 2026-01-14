# GitHub Repository Setup

Your local Git repository is ready! Here's how to push it to GitHub.

## Current Status ✓

```bash
✓ Git repository initialized
✓ Initial commit created (32 files, 2013+ lines)
✓ Branch renamed to 'main'
✓ .gitignore configured (orb.yml excluded)
```

---

## Step 1: Create GitHub Repository

### Option A: Using GitHub CLI (Recommended)

```bash
# Install GitHub CLI if not already installed
brew install gh

# Authenticate
gh auth login

# Create repository and push
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2
gh repo create artifactory-orb-v2 --public --source=. --remote=origin --push

# Done! Repository created and code pushed.
```

### Option B: Using GitHub Web Interface

1. **Go to GitHub**: https://github.com/new

2. **Fill in details**:
   - **Repository name**: `artifactory-orb-v2`
   - **Description**: `CircleCI Orb for JFrog Artifactory with CLI v2 support`
   - **Visibility**: Public (required for CircleCI orbs) or Private (for testing)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)

3. **Click "Create repository"**

4. **Push your code**:
   ```bash
   cd /Users/agrasthn/workspace/plugins/artifactory-orb-2
   
   # Add remote (replace YOUR-USERNAME with your GitHub username)
   git remote add origin https://github.com/YOUR-USERNAME/artifactory-orb-v2.git
   
   # Or use SSH
   git remote add origin git@github.com:YOUR-USERNAME/artifactory-orb-v2.git
   
   # Push to GitHub
   git push -u origin main
   ```

---

## Step 2: Verify Push

```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2
git remote -v
git log --oneline
```

Expected output:
```
origin  https://github.com/YOUR-USERNAME/artifactory-orb-v2.git (fetch)
origin  https://github.com/YOUR-USERNAME/artifactory-orb-v2.git (push)

8eb4c1b Initial commit: JFrog Artifactory CircleCI Orb v2
```

---

## Step 3: Enable CircleCI for This Repository

1. **Go to CircleCI**: https://app.circleci.com/

2. **Click "Projects"** in the left sidebar

3. **Find your repository**: `artifactory-orb-v2`

4. **Click "Set Up Project"**

5. **Choose config**: 
   - Select "Use Existing Config" (we have test-config.yml ready)
   - OR use test-local.yml for initial testing

6. **Add environment variables** (if testing with real Artifactory):
   - Go to Project Settings > Environment Variables
   - Add:
     - `ARTIFACTORY_URL` = `https://your-company.jfrog.io/artifactory`
     - `ARTIFACTORY_USER` = your username
     - `ARTIFACTORY_API_KEY` = your API key

---

## Step 4: Test the Orb in CircleCI

### Quick Test (Inline Orb - No Publishing)

```bash
# Copy test-local.yml to .circleci/config.yml
cd /Users/agrasthn/workspace/plugins/artifactory-orb-v2
mkdir -p .circleci
cp test-local.yml .circleci/config.yml

# Commit and push
git add .circleci/config.yml
git commit -m "Add CircleCI config for testing"
git push

# Check CircleCI dashboard - pipeline will trigger automatically
```

### Full Test (Published Dev Orb)

Follow the steps in [PUBLISH-GUIDE.md](PUBLISH-GUIDE.md):

1. Authenticate: `circleci setup`
2. Create namespace: `circleci namespace create YOUR-NAME github YOUR-ORG`
3. Create orb: `circleci orb create YOUR-NAMESPACE/artifactory-orb-v2`
4. Publish dev: `circleci orb publish orb.yml YOUR-NAMESPACE/artifactory-orb-v2@dev:test1`
5. Update config to use your published dev orb
6. Push and test

---

## Useful Commands

```bash
# Check repository status
git status

# View commit history
git log --oneline --graph --all

# Check remote configuration
git remote -v

# View what's ignored
git status --ignored

# Pack and validate orb locally
circleci orb pack src > orb.yml
circleci orb validate orb.yml

# List local branches
git branch -a
```

---

## What's Next?

After pushing to GitHub and enabling CircleCI:

1. ✅ Repository is public and version controlled
2. ✅ CircleCI can access your repository
3. ✅ You can follow [PUBLISH-GUIDE.md](PUBLISH-GUIDE.md) to:
   - Test locally with inline orb (easiest)
   - Publish as dev version
   - Share with team
   - Eventually publish to CircleCI registry

---

## Troubleshooting

### "Permission denied (publickey)"
- Use HTTPS instead: `git remote set-url origin https://github.com/YOUR-USERNAME/artifactory-orb-v2.git`
- OR setup SSH keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

### "Repository not found"
- Check the URL is correct
- Ensure you have access to the repository
- Try with HTTPS: `https://github.com/YOUR-USERNAME/artifactory-orb-v2.git`

### "Failed to push some refs"
- Pull first: `git pull origin main --rebase`
- Then push: `git push origin main`


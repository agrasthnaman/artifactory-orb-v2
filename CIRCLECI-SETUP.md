# CircleCI Testing Setup - Step by Step

Your code is pushed to GitHub! Now let's test it on CircleCI.

**Repository**: https://github.com/agrasth/artifactory-orb-v2
**Branch**: main
**Config**: `.circleci/config.yml` (inline orb, no publishing needed)

---

## Step 1: Enable Project in CircleCI

### 1.1 Go to CircleCI Projects
Open: https://app.circleci.com/projects

### 1.2 Find Your Repository
- Look for: `agrasth/artifactory-orb-v2`
- If you don't see it:
  - Click the organization dropdown (top-left)
  - Select your GitHub organization/username: `agrasth`

### 1.3 Set Up Project
- Click **"Set Up Project"** button next to `artifactory-orb-v2`

**You'll see: "What would you like to do in your project?"**
- Select: **"Build, test, and deploy your software application"**
- Click: **"Next"** or **"Continue"**

**Next screen:**
- CircleCI will detect your `.circleci/config.yml` file
- Select: **"Fastest: Use the .circleci/config.yml in my repo"**
- Click: **"Set Up Project"**

CircleCI will automatically trigger your first pipeline!

---

## Step 2: Configure Environment Variables (IMPORTANT)

Your orb needs JFrog credentials to work. Let's add them:

### 2.1 Navigate to Project Settings
1. Go to: https://app.circleci.com/projects
2. Click on **`artifactory-orb-v2`** project
3. Click the **"Project Settings"** button (top-right, gear icon)

### 2.2 Add Environment Variables
1. In the left sidebar, click: **"Environment Variables"**
2. Click: **"Add Environment Variable"** button
3. Add these three variables:

| Name | Value | Example |
|------|-------|---------|
| `ARTIFACTORY_URL` | Your JFrog URL | `https://your-company.jfrog.io/artifactory` |
| `ARTIFACTORY_USER` | Your JFrog username | `admin` or your username |
| `ARTIFACTORY_API_KEY` | Your JFrog API Key/Token | Get from JFrog Platform |

**How to get your JFrog credentials:**
- **URL**: Your JFrog platform URL
- **User**: Your JFrog username
- **API Key**: 
  1. Login to JFrog Platform
  2. Click your profile (top-right)
  3. Click "Edit Profile"
  4. Go to "Authentication Settings"
  5. Generate API Key or Access Token

---

## Step 3: Trigger a Build

### Option A: From CircleCI UI (Easiest)
1. Go to: https://app.circleci.com/pipelines/github/agrasth/artifactory-orb-v2
2. Click: **"Trigger Pipeline"** (top-right)
3. Leave branch as `main`
4. Click: **"Trigger Pipeline"**

### Option B: Push a Change
```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Make a small change
echo "# Testing" >> README.md
git add README.md
git commit -m "Trigger CircleCI test"
git push
```

### Option C: Re-run from Workflows
If a build already ran:
1. Go to the workflow/build
2. Click: **"Rerun Workflow from Start"**

---

## Step 4: Monitor the Build

### 4.1 View Pipeline
- URL: https://app.circleci.com/pipelines/github/agrasth/artifactory-orb-v2
- You'll see the workflow: `test-local-orb`

### 4.2 Expected Jobs
Your config will run this job:
- ✅ **test-install-and-configure**: Tests CLI installation and configuration

### 4.3 What to Look For

**Successful steps:**
1. ✅ Checkout code
2. ✅ Install JFrog CLI (downloads and installs `jf`)
3. ✅ Verify Installation (checks `jf --version`)
4. ✅ Configure JFrog CLI (sets up server connection)
5. ✅ Verify Configuration (shows server config)
6. ✅ Create Test File
7. ✅ Test Upload (if credentials are valid)

**Job should complete in:** ~1-2 minutes

---

## Step 5: View Results

### Success ✅
If everything works, you'll see:
```
✓ JFrog CLI installed successfully!
✓ JFrog CLI configured successfully!
✓ Configuration successful!
```

### Common Issues

#### ❌ "jf: command not found"
**Cause**: Installation failed or PATH issue
**Fix**: Check the "Install JFrog CLI" step logs

#### ❌ "Error: ARTIFACTORY_URL is not set"
**Cause**: Environment variables not configured
**Fix**: Go to Project Settings > Environment Variables and add them

#### ❌ "Artifactory response: 401 Unauthorized"
**Cause**: Invalid credentials
**Fix**: 
- Check ARTIFACTORY_USER is correct
- Regenerate ARTIFACTORY_API_KEY in JFrog
- Update environment variable in CircleCI

#### ❌ "Artifactory response: 404 Not Found"
**Cause**: Wrong URL or repository doesn't exist
**Fix**: Verify ARTIFACTORY_URL is correct (should end with `/artifactory`)

---

## Step 6: Test Without Real Artifactory (Optional)

If you don't have JFrog credentials yet, you can still test the CLI installation:

### 6.1 Update Config to Skip Upload
Edit `.circleci/config.yml` and comment out the upload test:

```yaml
- run:
    name: Test Upload (if configured)
    command: |
      echo "Skipping upload test - no credentials"
      # jf rt upload "test.txt" "test-repo/circleci/" --server-id=test-server
```

### 6.2 Commit and Push
```bash
git add .circleci/config.yml
git commit -m "Skip upload test for now"
git push
```

This will still test:
- ✅ CLI installation
- ✅ CLI configuration (will work without valid URL)
- ⏭️ Upload (skipped)

---

## Quick Commands Reference

```bash
# Check local changes
git status

# View CircleCI pipeline
open https://app.circleci.com/pipelines/github/agrasth/artifactory-orb-v2

# Trigger new build (make a change and push)
echo "" >> README.md
git add README.md
git commit -m "Trigger build"
git push

# View project settings
open https://app.circleci.com/settings/project/github/agrasth/artifactory-orb-v2
```

---

## What's Next?

After successful test:

1. ✅ **Orb works locally** - Your inline orb is functional
2. 📦 **Publish as dev version** - Follow [PUBLISH-GUIDE.md](PUBLISH-GUIDE.md)
3. 🚀 **Share with team** - Others can use your published orb
4. 📚 **Update prompts** - Add learnings to [jfrog-plugin-generator](../jfrog-plugin-generator/)

---

## Need Help?

- **CircleCI Docs**: https://circleci.com/docs/
- **Build Logs**: Click on any failed step to see detailed logs
- **Orb Validation**: Run `circleci orb validate orb.yml` locally first


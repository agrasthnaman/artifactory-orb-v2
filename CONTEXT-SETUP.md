# Using CircleCI Contexts for JFrog Credentials

## What is a CircleCI Context?

A **context** is a secure way to share environment variables across multiple projects in CircleCI. Instead of setting credentials in each project, you set them once in a context and reference it.

## Step 1: Find Your Context Name

### Check Existing Contexts
1. Go to: https://app.circleci.com/settings/organization
2. Click on your organization (e.g., `agrasth`)
3. Click: **"Contexts"** in the left sidebar
4. You'll see a list of your contexts

**Common names:**
- `jfrog-context`
- `artifactory-context`
- `production`
- etc.

**Note the exact name!** You'll need it in step 2.

## Step 2: Update the Config to Use Your Context

Edit `.circleci/config.yml` line ~76:

```yaml
workflows:
  test-local-orb:
    jobs:
      - test-install-and-configure
      
      - test-full-workflow:
          context: YOUR-CONTEXT-NAME-HERE  # ⬅️ Replace with your context name
```

**Example:**
```yaml
- test-full-workflow:
    context: jfrog-context  # If your context is named "jfrog-context"
```

## Step 3: Verify Context Has Required Variables

Your context must have these environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `ARTIFACTORY_URL` | Your JFrog Artifactory URL | `https://mycompany.jfrog.io/artifactory` |
| `ARTIFACTORY_USER` | JFrog username | `admin` or your username |
| `ARTIFACTORY_API_KEY` | JFrog API Key or Access Token | `AKC...` or `eyJ...` |
| `ARTIFACTORY_REPO` | (Optional) Repository name for uploads | `generic-local` or `libs-release-local` |

### To Add/Check Variables in Context:
1. Go to: https://app.circleci.com/settings/organization
2. Click: **"Contexts"**
3. Click on your context name
4. Click: **"Add Environment Variable"** (if needed)
5. Verify all three variables exist

## Step 4: Verify Repository Access to Context

Make sure your repository can use the context:

1. In your context settings, check **"Security"** section
2. Option 1: **All members** can use (easiest for testing)
3. Option 2: **Restricted** - Add your repository explicitly

## Step 5: Set Repository Name

The test uploads to a repository. By default, it uses `generic-local`.

### Option A: Add ARTIFACTORY_REPO to Context (Recommended)

1. Go to your context: https://app.circleci.com/settings/organization
2. Click on `jfrog-context`
3. Add environment variable:
   - **Name**: `ARTIFACTORY_REPO`
   - **Value**: Your repository name (e.g., `libs-release-local`)

**Common repository names:**
- `generic-local` (generic artifacts) - default
- `libs-release-local` (release artifacts)
- `libs-snapshot-local` (snapshot artifacts)
- `maven-local`, `npm-local`, etc.

### Option B: Create `generic-local` Repository

If you want to use the default `generic-local`:

1. Login to JFrog Platform
2. Go to: **Administration → Repositories → Repositories**
3. Click: **"Add Repository"** → **"Local Repository"**
4. Select Type: **"Generic"**
5. Repository Key: `generic-local`
6. Click: **"Create"**

### Verify Repository Exists

The pipeline will now check if the repository exists before uploading!

## What the Test Will Do

The `test-full-workflow` job will:

1. ✅ **Install** JFrog CLI
2. ✅ **Configure** with your credentials from context
3. ✅ **Create** test artifacts (text files, sample JAR)
4. ✅ **Upload** artifacts to Artifactory
5. ✅ **Collect** build information (Git, environment)
6. ✅ **Publish** build info to Artifactory
7. ✅ **Download** artifacts back (test download)

**Expected time:** ~2-3 minutes

## Quick Update Instructions

```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Edit the context name in .circleci/config.yml
# Line ~76: context: YOUR-CONTEXT-NAME

# Commit and push
git add .circleci/config.yml
git commit -m "Use CircleCI context for credentials"
git push
```

## Troubleshooting

### "No context found"
**Fix:** Update the context name to match exactly what's in your CircleCI organization

### "Missing environment variable"
**Fix:** Go to context settings and add the missing variable

### "Repository not found" or "Permission denied"
**Fix:** 
- Check ARTIFACTORY_URL is correct (should end with `/artifactory`)
- Verify repository `generic-local` exists
- Check your user has write permissions

### "Upload failed: 401 Unauthorized"
**Fix:**
- Regenerate API key in JFrog Platform
- Update ARTIFACTORY_API_KEY in your context

## View Results

After successful upload, find your artifacts:
1. Go to your JFrog Platform
2. Navigate to: **Artifactory → Artifacts**
3. Browse to: `generic-local/circleci-test/artifactory-orb-v2/{build-number}/`
4. View build info: **Builds → artifactory-orb-v2**

## Next Steps

Once this test passes:
- ✅ Your orb is fully functional!
- 📦 Ready to publish as dev version
- 🚀 Can be used by other projects


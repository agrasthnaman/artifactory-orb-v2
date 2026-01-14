# Testing the Real Orb (Not Inline)

You're right! We've been testing with an inline orb (embedded scripts) which doesn't test the actual orb structure we built in `src/`.

## Current State

- ✅ **Inline orb tested** - Shell script logic works
- ❌ **Real orb NOT tested** - The `src/` structure hasn't been validated

---

## Option 1: Publish Dev Version (Recommended)

This tests the **actual orb** as others would use it.

### Step 1: Setup CircleCI CLI Auth

```bash
circleci setup
# Paste your token from: https://app.circleci.com/settings/user/tokens
```

### Step 2: Create Namespace (If Not Exists)

```bash
# Check if you have a namespace
circleci orb list

# If empty, create one
circleci namespace create agrasth github agrasth
```

### Step 3: Pack the Orb

```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Pack src/ into single orb.yml
circleci orb pack src > orb.yml

# Validate
circleci orb validate orb.yml
```

### Step 4: Create the Orb (First Time Only)

```bash
circleci orb create agrasth/artifactory-orb-v2
```

### Step 5: Publish Dev Version

```bash
circleci orb publish orb.yml agrasth/artifactory-orb-v2@dev:test1
```

### Step 6: Create Test Config Using Published Orb

Create `.circleci/config-test-real-orb.yml`:

```yaml
version: 2.1

# Use the PUBLISHED orb, not inline!
orbs:
  artifactory: agrasth/artifactory-orb-v2@dev:test1

workflows:
  test-real-orb:
    jobs:
      # Test 1: Use orb's install command
      - test-commands
      
      # Test 2: Use orb's upload job
      - artifactory/upload:
          name: test-upload-job
          source: "*.txt"
          target: "${ARTIFACTORY_REPO:-libs-release-local}/circleci-test/${CIRCLE_BUILD_NUM}/"
          build-name: "test-build"
          build-number: "${CIRCLE_BUILD_NUM}"
          context: jfrog-context

jobs:
  test-commands:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      
      # Test orb commands
      - artifactory/install
      
      - run:
          name: Verify Install
          command: jf --version
      
      - artifactory/configure:
          server-id: "test-server"
          url: ${ARTIFACTORY_URL}
          user: ${ARTIFACTORY_USER}
          apikey: ${ARTIFACTORY_API_KEY}
      
      - run:
          name: Create Test File
          command: echo "Testing real orb" > test.txt
      
      - artifactory/upload:
          source: "test.txt"
          target: "${ARTIFACTORY_REPO:-libs-release-local}/orb-test/"
          server-id: "test-server"
      
      - artifactory/build-integration:
          build-name: "orb-test"
          build-number: "${CIRCLE_BUILD_NUM}"
          server-id: "test-server"
```

### Step 7: Update Main Config

```bash
# Backup current config
cp .circleci/config.yml .circleci/config-inline-test.yml

# Use real orb config
cp .circleci/config-test-real-orb.yml .circleci/config.yml

# Commit and push
git add .circleci/
git commit -m "Test real orb (published dev version)"
git push
```

---

## Option 2: Local Development with Orb File

Use the packed orb locally without publishing:

### Create Test Config

```yaml
version: 2.1

# Reference: You can't directly use a local orb file in CircleCI
# But you can validate it locally with: circleci config validate

orbs:
  artifactory: agrasth/artifactory-orb-v2@dev:test1

workflows:
  test:
    jobs:
      - artifactory/upload:
          source: "*.jar"
          target: "libs-release-local/"
```

### Validate Locally

```bash
# Pack the orb
circleci orb pack src > orb.yml

# Validate structure
circleci orb validate orb.yml

# Process config (expands orb references)
circleci config process .circleci/config.yml
```

---

## Key Differences

### Inline Orb (What we tested)
```yaml
orbs:
  artifactory:
    commands:
      install:
        steps:
          - run: curl... # Direct code
```
**Tests:** Logic only, not structure

### Real Orb (What we need to test)
```yaml
orbs:
  artifactory: agrasth/artifactory-orb-v2@dev:test1
  
workflows:
  build:
    jobs:
      - artifactory/upload:  # Uses actual orb job
          source: "*.jar"
          target: "libs-release-local/"
```
**Tests:** Full orb as users would consume it

---

## Recommended Flow

1. ✅ Pack the orb: `circleci orb pack src > orb.yml`
2. ✅ Validate: `circleci orb validate orb.yml`
3. ✅ Publish dev: `circleci orb publish orb.yml agrasth/artifactory-orb-v2@dev:test1`
4. ✅ Create test config using the published orb
5. ✅ Run in CircleCI
6. ✅ If it works, publish production version!

---

## Why This Matters

- **Inline orb:** Tests if the CLI commands work
- **Published orb:** Tests if:
  - ✅ Orb structure is correct (YAML syntax)
  - ✅ Parameters work correctly
  - ✅ Commands can be called from jobs
  - ✅ Jobs can be used in workflows
  - ✅ Executors are properly defined
  - ✅ Examples are valid
  - ✅ Others can actually use your orb!

---

## Quick Start

```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Setup (one time)
circleci setup

# Pack, validate, publish
circleci orb pack src > orb.yml
circleci orb validate orb.yml
circleci orb create agrasth/artifactory-orb-v2  # First time only
circleci orb publish orb.yml agrasth/artifactory-orb-v2@dev:test1

# Now update .circleci/config.yml to use:
# orbs:
#   artifactory: agrasth/artifactory-orb-v2@dev:test1
```

This is the **proper way** to test an orb!


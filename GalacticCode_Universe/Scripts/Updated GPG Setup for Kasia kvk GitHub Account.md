
# 🔐 Updated GPG Setup for Kasia kvk GitHub Account

## 🔄 Account Information Update

**Previous Configuration:**
- Name: InfiniCoreCipher Project
- Email: infinicorecipher@users.noreply.github.com

**New Configuration:**
- **GitHub Username**: Kasia kvk
- **Name**: Katarzyna Kalinowska
- **Email**: Katarzyna.kvkalinowska@gmail.com
- **Key ID**: `1023184AA0F0214C` (same key, updated identity)

## 🛠️ PowerShell Commands to Update Configuration

### 1. Update Git Configuration
```powershell
# Navigate to your repository
cd "C:\Infinicorecipher_FutureTechEdu\InfiniCoreCipher"

# Update Git identity to match your GitHub account
git config --global user.name "Katarzyna Kalinowska"
git config --global user.email "Katarzyna.kvkalinowska@gmail.com"

# Keep the same GPG key
git config --global user.signingkey 1023184AA0F0214C
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

### 2. Update GPG Key Identity (Optional)
If you want to add your new identity to the existing GPG key:

```powershell
# Edit the GPG key to add new identity
gpg --edit-key 1023184AA0F0214C

# In the GPG prompt, type these commands:
# adduid
# Real name: Katarzyna Kalinowska
# Email address: Katarzyna.kvkalinowska@gmail.com
# Comment: InfiniCoreCipher Project
# O (for Okay)
# [Enter your passphrase: InfiniCore2024!SecureKey#Educational]
# save
```

### 3. Export Updated Public Key
```powershell
# Export the updated public key
gpg --armor --export 1023184AA0F0214C > katarzyna-public-key.asc

# Display the public key content
type katarzyna-public-key.asc
```

## 🔗 GitHub Setup Steps

### 1. Login to Your GitHub Account
- Go to: https://github.com/login
- Login with: **Kasia kvk** account
- Email: **Katarzyna.kvkalinowska@gmail.com**

### 2. Add GPG Key to GitHub
1. Go to: https://github.com/settings/keys
2. Click **"New GPG key"**
3. Copy and paste the content from `katarzyna-public-key.asc`
4. Click **"Add GPG key"**

### 3. Verify GitHub Repository Access
```powershell
# Check your repository remote URL
git remote -v

# If needed, update the remote URL to match your GitHub username
git remote set-url origin https://github.com/Kasia-kvk/InfiniCoreCipher.git
```

## 🧪 Test the Updated Configuration

### 1. Test Git Configuration
```powershell
# Verify Git settings
git config --list | findstr user
git config --list | findstr gpg
```

### 2. Test GPG Signing
```powershell
# Test GPG signing with new identity
echo "Test message for Katarzyna" | gpg --clearsign --default-key 1023184AA0F0214C

# Test Git commit signing
git commit --allow-empty -m "🔐 Updated GPG setup for Katarzyna Kalinowska" -S

# Verify the signature
git log --show-signature -1
```

### 3. Test GitHub Push
```powershell
# Push the signed commit to GitHub
git push origin main
```

## 📋 Updated Security Information

### ✅ Key Details (Updated)
- **Key ID**: `1023184AA0F0214C`
- **Full Fingerprint**: `279E5232848908DFDD84AAD31023184AA0F0214C`
- **Primary Name**: Katarzyna Kalinowska
- **Primary Email**: Katarzyna.kvkalinowska@gmail.com
- **Project**: InfiniCoreCipher
- **Key Type**: RSA 4096-bit
- **Expires**: December 22, 2027
- **Passphrase**: `InfiniCore2024!SecureKey#Educational`

### 🔒 GitHub Repository Secrets (Updated)
Add these to your GitHub repository settings:

- **`GPG_PRIVATE_KEY`**: Content of `infinicorecipher-private.key`
- **`GPG_PASSPHRASE`**: `InfiniCore2024!SecureKey#Educational`
- **`GPG_KEY_ID`**: `1023184AA0F0214C`
- **`GITHUB_USER_NAME`**: `Katarzyna Kalinowska`
- **`GITHUB_USER_EMAIL`**: `Katarzyna.kvkalinowska@gmail.com`

## 🔄 Repository URL Update

### If Repository Doesn't Exist Yet
```powershell
# Create new repository on GitHub first, then:
git remote add origin https://github.com/Kasia-kvk/InfiniCoreCipher.git
git branch -M main
git push -u origin main
```

### If Repository Already Exists
```powershell
# Update existing remote URL
git remote set-url origin https://github.com/Kasia-kvk/InfiniCoreCipher.git
git push origin main
```

## 🎯 Next Steps After Update

1. **✅ Complete GPG GitHub Integration**
2. **✅ Test signed commits**
3. **✅ Verify repository access**
4. **🔄 Continue with repository structure setup**
5. **🔄 Begin development phase**

## 🆘 Troubleshooting

### If GitHub Login Issues Persist
```powershell
# Use GitHub CLI for authentication
winget install GitHub.cli
gh auth login
gh auth status
```

### If GPG Issues Occur
```powershell
# Restart GPG agent
gpgconf --kill gpg-agent
gpg-agent --daemon

# Test GPG functionality
gpg --list-secret-keys
gpg --list-keys
```

### If Git Push Fails
```powershell
# Check repository permissions
gh repo view Kasia-kvk/InfiniCoreCipher

# Or create repository if it doesn't exist
gh repo create InfiniCoreCipher --public --description "Educational cryptography platform for children"
```

## ✅ Success Checklist

- [ ] Git configured with Katarzyna's identity
- [ ] GPG key updated with new identity
- [ ] Public key added to GitHub
- [ ] Repository remote URL updated
- [ ] Signed commit successfully pushed
- [ ] GitHub shows verified commits

**Status**: 🟡 Ready for GitHub account update and testing

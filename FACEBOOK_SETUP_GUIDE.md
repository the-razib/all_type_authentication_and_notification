# Facebook Authentication Setup Guide

This guide will help you configure Facebook authentication for your Flutter app.

## Prerequisites

1. **Facebook Developer Account**: You need a Facebook Developer account to create a Facebook app.
2. **Facebook App**: You need to create a Facebook app in the Facebook Developer Console.

## Step 1: Create a Facebook App

1. Go to the [Facebook Developer Console](https://developers.facebook.com/)
2. Click on "My Apps" and then "Create App"
3. Select "Consumer" as the app type
4. Fill in your app details:
   - **App Name**: Authentication And Notification (or your preferred name)
   - **App Contact Email**: Your email address
5. Click "Create App"

## Step 2: Set up Facebook Login

1. In your Facebook app dashboard, click on "Add Product"
2. Find "Facebook Login" and click "Set Up"
3. Select "Android" and/or "iOS" depending on your target platforms

### For Android:
1. In the Facebook Login settings for Android:
   - **Package Name**: `com.example.authentication_and_notification`
   - **Default Activity Class Name**: `com.example.authentication_and_notification.MainActivity`
   - **Key Hashes**: You'll need to generate this (see instructions below)

### For iOS:
1. In the Facebook Login settings for iOS:
   - **Bundle ID**: Use the bundle ID from your iOS project (found in `ios/Runner.xcodeproj`)

## Step 3: Get Your Facebook App Credentials

1. In your Facebook app dashboard, go to "Settings" → "Basic"
2. Copy the following values:
   - **App ID**: This is your Facebook App ID
   - **App Secret**: This is your Facebook App Secret (keep this secure)
3. Go to "Settings" → "Advanced" → "Security"
4. Copy the **Client Token**

## Step 4: Configure Your Flutter App

### Android Configuration

Replace the placeholder values in `/android/app/src/main/res/values/strings.xml`:

```xml
<!-- Replace YOUR_FACEBOOK_APP_ID with your actual Facebook App ID -->
<string name="facebook_app_id">1234567890123456</string>
<!-- Replace YOUR_FACEBOOK_CLIENT_TOKEN with your actual Facebook Client Token -->
<string name="facebook_client_token">your_client_token_here</string>
<!-- Replace YOUR_FACEBOOK_APP_ID in the protocol scheme -->
<string name="fb_login_protocol_scheme">fb1234567890123456</string>
```

### iOS Configuration

Replace the placeholder values in `/ios/Runner/Info.plist`:

```xml
<!-- Replace YOUR_FACEBOOK_APP_ID with your actual Facebook App ID -->
<key>FacebookAppID</key>
<string>1234567890123456</string>
<!-- Replace YOUR_FACEBOOK_CLIENT_TOKEN with your actual Facebook Client Token -->
<key>FacebookClientToken</key>
<string>your_client_token_here</string>

<!-- In the CFBundleURLSchemes array, replace YOUR_FACEBOOK_APP_ID -->
<string>fb1234567890123456</string>
```

## Step 5: Generate Android Key Hash

To get the key hash for Android development:

### For Debug Key (Development):
```bash
# For macOS/Linux
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64

# For Windows
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64
```

Default password for debug keystore is usually `android`.

### For Release Key (Production):
```bash
keytool -exportcert -alias your_release_key_alias -keystore your_release_key.keystore | openssl sha1 -binary | openssl base64
```

## Step 6: Configure Facebook App Settings

1. In Facebook Developer Console, go to your app's "Facebook Login" settings
2. Add the following to "Valid OAuth Redirect URIs":
   - For Android: No additional setup needed if you've configured the key hashes correctly
   - For iOS: No additional setup needed if you've configured the bundle ID correctly

## Step 7: Test Your Implementation

1. Run your Flutter app
2. Try signing in with Facebook
3. Check that the authentication flow works correctly

## Common Issues and Solutions

### Issue: "Invalid key hash"
**Solution**: Make sure you've generated and added the correct key hash for your Android app.

### Issue: "App not configured correctly"
**Solution**: Verify that your Facebook App ID and Client Token are correctly set in both the Facebook Developer Console and your app configuration files.

### Issue: "Login cancelled"
**Solution**: This usually happens when the user cancels the login flow or when there's a configuration issue.

### Issue: iOS build fails
**Solution**: Make sure you've added the Facebook SDK to your iOS project and configured the Info.plist correctly.

## Security Best Practices

1. **Never commit secrets**: Don't commit your Facebook App Secret to version control
2. **Use environment variables**: For production apps, use environment variables or secure configuration management
3. **Validate on server**: Always validate Facebook tokens on your backend server
4. **Use HTTPS**: Ensure all communication uses HTTPS

## Additional Configuration for Production

For production apps, you should:

1. Set up proper error handling and logging
2. Implement token refresh mechanisms
3. Add proper user consent flows
4. Configure Facebook app review if required
5. Set up analytics and monitoring

## Next Steps

After completing this setup:

1. Test the Facebook login flow thoroughly
2. Implement proper error handling for edge cases
3. Add user profile management features
4. Consider implementing account linking if users can sign in with multiple methods

## Support

If you encounter issues:

1. Check the Facebook Developer documentation
2. Verify all configuration values are correct
3. Test with a fresh Facebook app if problems persist
4. Check Flutter Facebook Auth plugin documentation for updates

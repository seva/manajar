from playwright.sync_api import sync_playwright
import time
import os

USER_DATA_DIR = os.path.expanduser("~/.manajar-browser-profile")

def setup_oauth():
    with sync_playwright() as p:
        # Persistent context saves cookies/sessions between runs
        context = p.chromium.launch_persistent_context(
            USER_DATA_DIR,
            headless=False,
            args=["--disable-blink-features=AutomationControlled"],
        )
        page = context.pages[0] if context.pages else context.new_page()
        
        page.goto("https://console.cloud.google.com/")
        time.sleep(5)
        
        # Dismiss the banner
        try:
            dismiss = page.locator("button:has-text('Dismiss')").first
            if dismiss.is_visible():
                dismiss.click()
                time.sleep(1)
        except:
            pass
        
        # Click on APIs & Services
        print("1. Enabling Gemini API...")
        page.get_by_role("link", name="APIs & Services").click()
        time.sleep(3)
        
        # Click on Library
        page.get_by_role("link", name="Library").click()
        time.sleep(3)
        
        # Search for Gemini API
        search_box = page.locator("input[placeholder*='Search']")
        search_box.fill("Gemini API")
        time.sleep(2)
        
        # Click on Gemini API result
        page.locator("text=Gemini API").first.click()
        time.sleep(3)
        
        # Enable the API
        enable_btn = page.locator("button:has-text('Enable')")
        if enable_btn.is_visible():
            enable_btn.click()
            print("Gemini API enabled!")
            time.sleep(5)
        else:
            print("Gemini API already enabled")
        
        # Go to Credentials
        print("\n2. Creating OAuth credentials...")
        page.goto("https://console.cloud.google.com/apis/credentials")
        time.sleep(5)
        
        # Click Create Credentials
        page.locator("button:has-text('Create Credentials')").click()
        time.sleep(2)
        
        # Select OAuth client ID
        page.locator("text=OAuth client ID").click()
        time.sleep(3)
        
        # Configure OAuth consent screen if needed
        try:
            configure_btn = page.locator("button:has-text('Configure consent screen')")
            if configure_btn.is_visible():
                configure_btn.click()
                time.sleep(3)
                
                # Select External
                page.locator("label:has-text('External')").click()
                time.sleep(1)
                page.locator("button:has-text('Create')").click()
                time.sleep(3)
                
                # Fill app name
                page.fill("input[name='applicationName']", "ManaJar")
                time.sleep(1)
                
                # Fill support email
                page.fill("input[name='supportEmail']", "seva.lapsha@gmail.com")
                time.sleep(1)
                
                # Click Save and Continue
                page.locator("button:has-text('Save and continue')").click()
                time.sleep(2)
                
                # Skip scopes
                page.locator("button:has-text('Save and continue')").click()
                time.sleep(2)
                
                # Add test user
                page.locator("button:has-text('Add users')").click()
                time.sleep(1)
                page.fill("input[placeholder*='email']", "seva.lapsha@gmail.com")
                time.sleep(1)
                page.locator("button:has-text('Add')").click()
                time.sleep(1)
                page.locator("button:has-text('Save and continue')").click()
                time.sleep(2)
                
                # Back to dashboard
                page.locator("button:has-text('Back to dashboard')").click()
                time.sleep(3)
        except Exception as e:
            print(f"Consent screen config: {e}")
        
        # Create OAuth client ID
        page.goto("https://console.cloud.google.com/apis/credentials")
        time.sleep(5)
        page.locator("button:has-text('Create Credentials')").click()
        time.sleep(2)
        page.locator("text=OAuth client ID").click()
        time.sleep(3)
        
        # Select Web application
        page.locator("text=Web application").click()
        time.sleep(2)
        
        # Name
        page.fill("input[name='name']", "ManaJar OAuth")
        time.sleep(1)
        
        # Add redirect URI
        page.locator("button:has-text('Add URI')").click()
        time.sleep(1)
        page.fill("input[placeholder*='https://']", "https://web-app-zeta-six-27.vercel.app/api/auth/gemini")
        time.sleep(1)
        
        # Create
        page.locator("button:has-text('Create')").click()
        time.sleep(5)
        
        # Extract credentials
        print("\n3. Extracting credentials...")
        try:
            dialog = page.locator("[role='dialog']").first
            client_id_elem = dialog.locator("text=Your Client ID").locator("xpath=following-sibling::*").first
            client_secret_elem = dialog.locator("text=Your Client Secret").locator("xpath=following-sibling::*").first
            
            client_id = client_id_elem.text_content()
            client_secret = client_secret_elem.text_content()
            
            print(f"\n✅ Client ID: {client_id}")
            print(f"✅ Client Secret: {client_secret}")
            
            # Save to file
            with open("C:\\Users\\seval\\manajar\\web-app\\.env.local", "w") as f:
                f.write(f"GOOGLE_CLIENT_ID={client_id}\n")
                f.write(f"GOOGLE_CLIENT_SECRET={client_secret}\n")
                f.write(f"NEXT_PUBLIC_APP_URL=https://web-app-zeta-six-27.vercel.app\n")
            
            print("\n✅ Credentials saved to .env.local")
        except Exception as e:
            print(f"\n⚠️ Could not extract credentials automatically: {e}")
            print("Please copy them from the dialog and press Enter when ready...")
            input()
        
        print("\nDone! Press Ctrl+C to close browser")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            context.close()

if __name__ == "__main__":
    setup_oauth()

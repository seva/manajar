from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    page = browser.new_page()
    page.goto("https://console.cloud.google.com/")
    time.sleep(5)
    page.screenshot(path="C:\\Users\\seval\\manajar\\docs\\gcloud-current.png")
    print("Screenshot saved. Current URL:", page.url)
    print("Page title:", page.title())
    # Keep browser open
    input("Press Enter to close...")
    browser.close()

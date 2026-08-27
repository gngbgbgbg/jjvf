import requests
import time
import random

class X3UIClient:
    def __init__(self, base_url, username, password):
        self.base_url = base_url.rstrip('/')
        self.username = username
        self.password = password
        self.session = requests.Session()
        
        # تنظیم هدرهای کاملاً مشابه مرورگر واقعی
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "fa-IR,fa;q=0.9,en-US;q=0.8,en;q=0.7",
            "Origin": self.base_url,
            "Referer": f"{self.base_url}/panel/",
            "X-Requested-With": "XMLHttpRequest"
        })

    def login(self):
        """ورود به پنل و ذخیره کوکی نشست"""
        login_url = f"{self.base_url}/login"
        payload = {
            "username": self.username,
            "password": self.password
        }
        
        try:
            # تاخیر کوتاه‌ قبل از لاگین
            time.sleep(random.uniform(0.5, 1.5))
            
            response = self.session.post(login_url, data=payload, timeout=10)
            res_json = response.json()
            
            if res_json.get("success"):
                print("[+] لاگین موفقیت‌آمیز بود و نشست فعال شد.")
                return True
            else:
                print(f"[-] خطا در لاگین: {res_json.get('msg')}")
                return False
        except Exception as e:
            print(f"[-] خطای ارتباطی هنگام لاگین: {e}")
            return False

    def get_inbounds(self):
        """دریافت لیست اینباندها با تاخیر ایمن"""
        url = f"{self.base_url}/panel/api/inbounds/list"
        
        # وقفه تصادفی برای طبیعی جلوه دادن درخواست (بین ۱ تا ۲.۵ ثانیه)
        time.sleep(random.uniform(1.0, 2.5))
        
        try:
            response = self.session.get(url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                if data.get("success"):
                    return data.get("obj")
            
            # اگر 404 یا 401 داد ممکن است نشست پریده باشد
            if response.status_code in [401, 403]:
                print("[!] نشست منقضی شده، تلاش مجدد برای لاگین...")
                if self.login():
                    return self.get_inbounds()
                    
        except Exception as e:
            print(f"[-] خطای دریافت اطلاعات: {e}")
            
        return None

# --- نحوه استفاده ---
if __name__ == "__main__":
    # آدرس پنل به همراه پورت و مسیر (اگر مسیر اختصاصی داری اضافه کن)
    PANEL_URL = "http://YOUR_SERVER_IP:2053" 
    USERNAME = "admin"
    PASSWORD = "admin_password"

    bot = X3UIClient(PANEL_URL, USERNAME, PASSWORD)
    
    if bot.login():
        inbounds = bot.get_inbounds()
        if inbounds:
            print(f"[+] تعداد {len(inbounds)} اینباند با موفقیت خوانده شد.")

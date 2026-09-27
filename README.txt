PORTFOLIO + SUPABASE
====================

این پروژه از Supabase برای Authentication، PostgreSQL Database و Storage استفاده می‌کند.

راه‌اندازی:
1) در https://supabase.com یک پروژه بساز.
2) فایل supabase-setup.sql را در SQL Editor اجرا کن.
3) Authentication > Users > Add user: یک ایمیل/رمز برای ادمین بساز.
4) UUID همان کاربر را کپی کن و دستور انتهای supabase-setup.sql را با UUID واقعی اجرا کن.
5) از Project Settings > API، Project URL و anon/publishable key را بردار و در supabase-config.js قرار بده.
6) فایل‌ها را روی Netlify / Vercel / Cloudflare Pages یا هر هاست استاتیک آپلود کن.
7) index.html سایت عمومی است و admin.html پنل مدیریت.

نکته امنیتی:
- service_role key را هرگز داخل فایل‌های سایت قرار نده.
- anon/publishable key برای استفاده در مرورگر طراحی شده و امنیت واقعی توسط RLS اعمال می‌شود.
- فقط UUID موجود در portfolio_admins اجازه تغییر اطلاعات و تصاویر را دارد.

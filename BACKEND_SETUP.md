# Share a Meal — Backend setup

The GitHub Pages website is static. It cannot host a private database or securely hold admin credentials. This repository includes a Supabase schema starter; a Supabase project and its public project URL/key must be configured before cross-device data can work.

## 1. Create a Supabase project
1. Sign in at https://supabase.com/ and create a project.
2. Open **SQL Editor**, paste the full contents of `supabase-schema.sql`, and run it.
3. Open **Project Settings → API** (or Connect) and copy the Project URL and the **publishable/anon key**. Never put a service-role key in a website.

## 2. Configure the website
The frontend backend adapter is not activated until a project URL and publishable key are supplied. Add them only to the public frontend config. These values are designed to be public; row-level security (RLS) policies in the schema are the security boundary. Never expose a service-role/secret key.

## 3. Configure admin access
Create the admin user through Supabase Authentication. Then, in the Supabase SQL editor, assign the role to that user through the Auth user record's app_metadata using a trusted server-side/admin method. Do not let users set their own admin role from the browser. Policies restrict update/delete and feedback/notification access to users whose JWT app_metadata role is `admin`.

## 4. Important deployment notes
- After configuration, test with two different browsers/devices.
- GitHub Pages only hosts the frontend; it does not send email/push notifications by itself.
- Real-time alerts need a subscribed client and/or a notification provider. Email/SMS/push delivery requires additional provider setup.
- This schema is a secure starting point, not a claim that the live site is already connected. Until credentials are configured and the frontend adapter is enabled, the existing site remains in local-demo mode.

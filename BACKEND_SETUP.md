# Share a Meal — Backend setup and troubleshooting

The GitHub Pages frontend uses the Supabase project URL and a publishable key. A publishable key is meant for browser use; database security must come from Row Level Security (RLS). Never place a Supabase secret/service-role key in `index.html`, GitHub Pages, or any browser code.

## Current architecture

- GitHub Pages hosts the static website.
- Supabase Auth handles sign-up and sign-in.
- Supabase REST stores food requests and feedback.
- Signed-in users can submit listings tied to their Auth user ID.
- A signed-in user can see their own pending requests. Visitors see only approved/completed listings on the public board.
- Users cannot change listing status or delete shared requests. Admin users can review all requests and change status/delete through the board.
- The History section combines the signed-in user's own database requests with local alerts. It is not an email, SMS, or push notification system.

## Required one-time database setup

After deploying the code, open **Supabase Dashboard → SQL Editor**, paste the entire current `supabase-schema.sql` file from this repository, and run it. This migration adds `user_id`, changes the listing policies, and removes anonymous listing submissions. Existing older rows without a user ID are not visible as private user requests; admins can still review them.

If the SQL migration has not been run, sign-in may work but submitting a request will fail because the new `user_id` column and policies will not be active.

## Create an admin account

1. Open the live website, go to **Account**, and create an account with an email you control.
2. If email confirmation is enabled, confirm the email and sign in.
3. In Supabase **Authentication → Users**, find that account and copy its exact email.
4. Open **SQL Editor** and run the statement below after replacing the email with your own admin email:

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
where email = 'YOUR_ADMIN_EMAIL';
```

5. Sign out and sign in again so the browser receives a fresh token. The Account area should show **Admin access enabled**. The admin can then review pending requests on the Community Board and approve, complete, reject, or delete them.

Only trusted project owners should receive the admin role. Do not set the role through a user-editable profile field or browser code.

## If the website shows a connection or authentication error

1. Open the live site and press **Ctrl + F5** to load the latest deployment.
2. In Supabase, confirm the project is active and the URL/key belong to this project.
3. In **Authentication → Providers**, make sure Email sign-in is enabled. Check whether email confirmation is required.
4. In **API Settings**, confirm the Data API is enabled and the `public` schema is exposed.
5. Confirm the complete `supabase-schema.sql` file was run successfully.
6. Open browser developer tools (**F12 → Console**) and note the exact error/status. Never share a secret/service-role key.

## Privacy and limitations

- Pending requests are private to the account that created them and project admins. Approved/completed listings become visible on the public board, including their name/nickname and area; use demo details unless public sharing is intended.
- Existing anonymous rows cannot be assigned to an account automatically. They have a null `user_id`; admins can review them.
- Account session tokens are stored in the browser's local storage, as with many static Supabase Auth demos. Sign out on shared computers.
- Feedback can still be submitted publicly. Feedback reading is admin-only.
- This is a college prototype, not an emergency food service. Real food distribution requires verified partners, food-safety procedures, moderation, and a safe contact process.
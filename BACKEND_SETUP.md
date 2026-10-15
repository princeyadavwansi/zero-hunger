# Share a Meal — Backend setup and troubleshooting

The live frontend is configured to use the Supabase project URL and a publishable key. The publishable key is intentionally public; database access must be protected by Row Level Security (RLS). Never place a Supabase secret/service-role key in `index.html`, GitHub Pages, or any browser code.

## Current architecture
- GitHub Pages hosts the static website.
- Supabase REST API stores and returns community listings and feedback.
- Public visitors can submit listings and feedback according to the policies in `supabase-schema.sql`.
- Public visitors cannot update/delete shared listings. The status and delete controls are hidden while the shared backend is active.
- The History & Alerts section currently derives activity from listings. Read/unread state is local to each browser; it is not a shared notification system and does not send email, SMS, or push alerts.

## If the website shows “Connection needs attention”
1. Open the live site and press **Ctrl + F5** to reload the latest deployment.
2. In Supabase, confirm the project is active and the URL matches the frontend configuration.
3. In **Project Settings → API** (or **Connect**), confirm the publishable key belongs to this project.
4. In **SQL Editor**, run/inspect `supabase-schema.sql`. Confirm `public.listings` and `public.feedback` exist and RLS is enabled.
5. In **API Settings**, confirm the Data API is enabled and the `public` schema is exposed.
6. Open browser developer tools (**F12 → Console**). If there is still an error, copy the exact message and status code. Do not share any secret/service-role key.

## Database policies
The SQL file allows public reads of listings whose status is Pending, Approved, or Completed and allows public inserts only with Pending status. Feedback can be inserted publicly; feedback reading and listing updates/deletes are restricted to authenticated admin users whose JWT `app_metadata.role` is `admin`. Do not allow users to assign their own admin role.

## Deployment and verification
- GitHub Pages deployment may take a short time after a commit.
- Test submission and reload using two separate browsers/devices to verify shared persistence.
- Do not enter real people's sensitive information in this student prototype.
- Real food distribution requires verified partners, food-safety procedures, moderation, and a safe way to contact participants.
- Shared notification records, real-time updates, and email/SMS/push delivery require additional policies, client subscriptions, and/or a trusted notification service. They are not currently implemented.

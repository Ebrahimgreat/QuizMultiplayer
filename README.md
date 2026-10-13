Quiz Multiplier is a role-based quiz platform where creators can build quizzes by category and players can join and play. Built with Nuxt and Supabase, it supports live gameplay and secure access through RBAC (Role-Based Access Control).

✨ Features
	•	🔑 Authentication & RBAC – Role-based dashboards for quiz creators and players
	•	📝 Quiz Creation – Creators can design quizzes by category with flexible question types
	•	🎮 Quiz Playing – Players can take quizzes in real time or asynchronously
	•	⚡ Live Support – Host live quiz sessions with multiple players
	•	📊 Score Tracking – View results and leaderboard after each quiz

🚀 Tech Stack
	•	Frontend: Nuxt
	•	Backend & Database: Supabase
	•	Auth & RBAC: Supabase Auth
	•	Live Features: Supabase Realtime


🛠️ Setup
	1.	Create a free project at https://supabase.com/dashboard
	2.	npm install
	3.	npm run db:setup – logs in to Supabase, lets you pick your project, and creates all tables, functions and realtime settings from supabase/migrations
	4.	cp .env.example .env and fill in SUPABASE_URL and SUPABASE_KEY (anon key) from Project Settings → API
	5.	npm run dev

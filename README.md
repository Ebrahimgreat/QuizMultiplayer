<p align="center">
  <img src="public/rabbit.png" alt="Quiz Rabbit" width="96">
</p>

# Quiz Rabbit (Quiz Multiplayer)

A live multiplayer quiz game built with Nuxt and Supabase. Creators write quizzes, and players compete on them: alone, by challenging another player, or head-to-head in a real-time 1v1 match. Every game earns points on a shared leaderboard.

## Features

- **Two roles.** *Quiz creators* write and manage quizzes. *Players* play them.
- **Three ways to play:**
  - **Solo:** take any quiz on your own.
  - **Challenge:** play a quiz, then send it to another player. They play the same quiz later, and the higher score wins.
  - **Live 1v1:** two players join the same room and answer each question at the same time, with scores updated live.
- **Leaderboard** with points, games played and your rank.
- **Sample quizzes** come with the database, so there's something to play right away.
- **Categories:** Math, Sports, Science, Journalling, Art and Travel.

## Tech stack

| Part | Uses |
| --- | --- |
| Frontend | Nuxt 3, Vue 3, Pinia, Tailwind CSS |
| Database | Supabase Postgres with row-level security |
| Auth | Supabase Auth (email + password) |
| Live games | Supabase Realtime (Presence + Broadcast channels) |

## Getting started

### Requirements

- Node.js 18 or newer
- A free [Supabase](https://supabase.com/dashboard) account

The Supabase CLI is installed as a dev dependency, so you don't need to install it globally.

### Setup

1. **Clone and install**

   ```bash
   git clone https://github.com/Ebrahimgreat/QuizMultiplayer.git
   cd QuizMultiplayer
   npm install
   ```

2. **Create a Supabase project** at https://supabase.com/dashboard.

3. **Create the database**

   ```bash
   npm run db:setup
   ```

   This logs you in to Supabase, asks you to pick your project, and runs everything in [`supabase/migrations`](supabase/migrations): the tables, security policies, the stats function, realtime settings and the sample quizzes.

4. **Add your keys**

   ```bash
   cp .env.example .env
   ```

   Fill in `SUPABASE_URL` and `SUPABASE_KEY` (the **anon / public** key) from **Project Settings → API** in the Supabase dashboard.

5. **Run it**

   ```bash
   npm run dev
   ```

   Open http://localhost:3000.

> **Email confirmation:** new Supabase projects make users confirm their email before logging in. For local testing you can turn this off under **Authentication → Providers → Email → Confirm email**.

## How to play

### 1. Create an account

Go to **Register**, enter a name, email and password, and choose a role:

- **Player:** play quizzes, challenge friends and climb the leaderboard.
- **Quiz creator:** write quizzes for players.

### 2. As a quiz creator

1. Open **Create quiz** from the navigation bar.
2. Give the quiz a name, pick a category and add questions. Each question has four options (A–D) and one correct answer.
3. Click **Publish quiz**. It goes live for players right away.
4. Your **Home** page lists your quizzes. Use **Hide** to take one offline and **Make live** to bring it back.

### 3. As a player

Open **Play**, filter by category if you like, and pick a quiz. Then choose a mode:

| Mode | How it works |
| --- | --- |
| **Play solo** | Answer each question and check your answer as you go. You'll see your score at the end. |
| **Challenge a player** | Choose an opponent, then play the quiz. The challenge appears on their **Home** page as *Your turn*. When they finish, the higher score wins (or it's a draw). |
| **Play live** | You enter a live room for that quiz. When a second player joins, the match starts. Both of you lock in an answer for each question, both answers are revealed together, and you move on as a pair. Scores update live. |

Your **Home** page shows your points, rank and challenge history (*Won*, *Lost*, *Draw*, *Your turn*, *Waiting*). **Leaderboard** ranks every player by points.

### Trying a live match by yourself

You need two player accounts in two separate browser sessions:

1. Register two **Player** accounts.
2. Log in to one in a normal window and the other in a private/incognito window (or a different browser).
3. In both windows, pick the **same quiz** and choose **Play live**. The game starts as soon as the second player joins.

Each quiz has its own room, and each room holds two players. A third person who joins sees that the room is full.

## Project structure

```
pages/            Screens: login, register, home, quiz, lobby (live 1v1), quizScreen/quizTaking (solo + challenge), leaderboard
components/       Shared UI: quiz creator form, question card, role picker, auth card
composables/      useQuiz.ts: categories, quiz loading, answer checking
stores/           Pinia stores (signed-in profile and role)
middleware/       auth.global.ts: sends signed-out users to /login
supabase/         Database migrations (schema, policies, realtime, sample quizzes)
```

### How live games work

[`pages/lobby.vue`](pages/lobby.vue) opens one Supabase Realtime channel per quiz (`quiz-lobby-<quizId>`):

- **Presence** tracks who is in the room. The first two people to join are the players, and whoever joined first is the host.
- The host creates a `challenge` row and broadcasts a `start` event.
- Each player broadcasts an `answer` event when they lock in. Once both have answered, both clients reveal the question and move to the next one.
- At the end, the host saves the final scores and updates both players' stats.

## Scripts

| Command | What it does |
| --- | --- |
| `npm run dev` | Start the dev server |
| `npm run build` | Build for production |
| `npm run preview` | Preview the production build |
| `npm run db:setup` | Link a Supabase project and push the migrations |

## Contributing

Issues and pull requests are welcome. If you change the database, add a new file in `supabase/migrations` rather than editing an existing one, so people with an existing setup can update by running `npm run db:setup` again.

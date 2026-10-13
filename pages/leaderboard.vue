<script setup lang="ts">
import { useRoleStore } from "~/stores/role";

const roleStore = useRoleStore();
const loading = ref(true);
const userStats = ref([]);

async function getStats() {
  const supabase = useSupabaseClient();

  const { data: statsData, error } = await supabase
      .from("stats")
      .select("points, games_played, profiles!inner(id, name, role)")
      .eq("profiles.role", "player")
      .order("points", { ascending: false });
  if (error) {
    console.log(error);
  }

  const { data: wins } = await supabase.from("challenge").select("winner").not("winner", "is", null);
  const winCount = {};
  (wins ?? []).forEach((w) => {
    winCount[w.winner] = (winCount[w.winner] ?? 0) + 1;
  });

  // players on the same points share a rank
  let rank = 0;
  userStats.value = (statsData ?? []).map((item, index, all) => {
    if (index === 0 || item.points !== all[index - 1].points) rank = index + 1;
    return {
      id: item.profiles.id,
      name: item.profiles.name || "Unnamed player",
      points: item.points,
      games: item.games_played,
      wins: winCount[item.profiles.id] ?? 0,
      rank
    };
  });
  loading.value = false;
}

const medal = { 1: "bg-amber-400 text-cocoa-900", 2: "bg-slate-300 text-slate-800", 3: "bg-orange-300 text-orange-900" };

onMounted(() => {
  getStats();
});
</script>

<template>
  <div class="page max-w-3xl">
    <h1 class="page-title">Leaderboard</h1>
    <p class="text-cocoa-500 mt-1 mb-6">Every right answer earns 10 points.</p>

    <div v-if="loading" class="card p-6 text-cocoa-500">Loading…</div>
    <div v-else-if="userStats.length === 0" class="card p-8 text-center">
      <p class="font-bold">No players yet</p>
      <p class="text-cocoa-500 mt-1">Play a quiz to get on the board.</p>
    </div>
    <div v-else class="table-wrap">
      <table>
        <thead>
        <tr>
          <th class="w-16">Rank</th>
          <th>Player</th>
          <th class="text-right">Points</th>
          <th class="text-right hidden sm:table-cell">Games</th>
          <th class="text-right">Wins</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="item in userStats" :key="item.id" :class="item.id == roleStore.id ? 'bg-amber-50' : ''">
          <td>
            <span class="h-8 w-8 rounded-full grid place-items-center font-display font-bold" :class="medal[item.rank] ?? 'bg-cocoa-50 text-cocoa-500'">
              {{ item.rank }}
            </span>
          </td>
          <td class="font-bold">
            {{ item.name }}
            <span v-if="item.id == roleStore.id" class="pill bg-amber-200 text-amber-900 ml-1">You</span>
          </td>
          <td class="text-right font-display text-lg font-bold">{{ item.points }}</td>
          <td class="text-right hidden sm:table-cell">{{ item.games }}</td>
          <td class="text-right">{{ item.wins }}</td>
        </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

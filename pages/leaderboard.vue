<script setup lang="ts">
import { useRoleStore } from "~/stores/role";
import { useSupabaseUser } from "#imports";
const roleStore = useRoleStore();
let role = roleStore.role;

async function challengePlayer(item) {
  alert(`Invitation to ${item.name} Has been sent`);
}
async function getUser() {
  let supabase = useSupabaseClient();
  console.log(supabase.auth.getUser());
}
let quizInformation = ref([]);
async function getAllQuiz() {
  let supabase = useSupabaseClient();
  const currentUser = useSupabaseUser();
  try {
    const { data: quizData, error: quizError } = await supabase
        .from("quiz")
        .select("*")
        .eq("users_id", currentUser.value);
    if (quizError) {
      console.log("Unable to fetch");
      return;
    }
    quizInformation.value = quizData;
  } catch (error) {
    console.log(error);
  }
}



let teachers = ref();

let profiles = ref([]);

let stats=ref([])

let userStats=ref([])
async function  getstats()
{
  let supabase=useSupabaseClient();
  try {
    const {data: statsData, error: errorData} = await supabase.from('stats').select('*').order('points',{ascending:false})
    stats.value = statsData;

    const profileIds = statsData.map((item) => item.user_profile_id)


    const {data: profileData, error: profileError} = await supabase
        .from("profiles")
        .select("*").in('id', profileIds)
    console.log(profileData)

    if (profileError) {
      console.log("Error");
      return;
    }
    userStats.value=statsData?.map((stat)=>({
      ...stat,
      profile:profileData.find((profile)=>profile.id===stat.user_profile_id)
    }))
  }

  catch(error){
    console.log(error)
  }

}

async function getCurrentUser() {
  const supabase = useSupabaseClient();

  const { data, error } = await supabase.auth.getUser();

  if (error) {
    console.error("Error fetching current user:", error);
  } else {
    console.log("Current user ID:", data.user?.id);
    console.log("Current user email:", data.user?.email);
  }
}

onMounted(() => {

  getstats()
});
</script>

<template>
  <div class="bg-gray-900 h-screen w-full p-6 text-white">


    <div>
      <h2 class="text-2xl text-center mb-4">
       Leaderboard
      </h2>

      <table class="w-full bg-white text-gray-900 rounded-lg shadow-lg mb-6">
        <thead>
        <tr class="bg-gray-800 text-white">
          <th class="p-4">Name</th>
          <th class="p-4">Ranking</th>
          <th class="p-4">Total Points</th>
          <th class="p-4">Games Won</th>

        </tr>
        </thead>
        <tbody>
        <tr v-for="item in userStats" :key="item.id" class="border-b">
          <td class="p-4">{{item.profile.name }}</td>
          <td class="p-4"></td>
          <td class="p-4">{{item.points}}</td>
          <td class="p-4"></td>

        </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
/* Add any additional styles here */
button:hover {
  background-color: #e53e3e; /* Darker red for hover effect */
}
</style>

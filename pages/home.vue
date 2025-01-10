<script setup lang="ts">
import { SupabaseClient } from "@supabase/supabase-js";
import { getData } from "@redocly/ajv/lib/compile/validate";
import { useRoleStore } from "#imports";
const useRole = useRoleStore();
import { useSupabaseUser } from "#imports";


let playerChallenge=ref([])

let role = useRole.role;
let name = useRole.name;
let user = ref();
let profile = useRole.id;
let quizNames = ref([]);

let challenges = ref([]);

let challengePlayers =ref([]);

let names = ref([]);
async function getChallenges() {
  let supabase = useSupabaseClient();

  try {
    const { data: challengeValues, error: challengeErrors } = await supabase
        .from("challenge")
        .select("*")
        .or(`challenger_id.eq.${profile},reciever_id.eq.${profile}`);

    if (challengeErrors) {
      console.log(challengeErrors);
    }

    challenges.value = challengeValues;
    console.log("values",challenges.value)


    const userIds = [
      ...new Set([
        ...challengeValues?.map((challenge) => challenge.challenger_id),
        ...challengeValues?.map((challenge) => challenge.reciever_id),
      ]),
    ];
    console.log("Users",userIds)



    const quizIds = [
      ...new Set(challengeValues?.map((challenge) => challenge.quiz_id)),
    ];


    const { data: userProfiles, error: profileError } = await supabase
        .from("profiles")
        .select("id,name")
        .in("id", userIds);

    console.log("Profiles", userProfiles);


    challengePlayers.value = challengeValues?.map((challenge) => ({
      ...challenge,
      user_profile_name: userProfiles.find(
          (user) => user.id === challenge.reciever_id
      )?.name|| 'unkown',
      challenger_name: userProfiles.find(
          (user) => user.id === challenge.challenger_id
      )?.name || 'unkown'
    }))??[];
    console.log("players",challengePlayers.value)
  } catch (error) {
    console.log(error);
  }
}

let stats = ref([]);
async function getStats() {
  let currentProfile = useRoleStore().id;
  console.log("curr", currentProfile);
  let supabase = useSupabaseClient();
  try {
    const { data: statsValues, error: errorValues } = await supabase
        .from("stats")
        .select("*")
        .eq("user_profile_id", currentProfile)
        .single();

    if (errorValues) {
      console.log(errorValues);
    }
    stats.value = statsValues;

  } catch (error) {
    console.log(error);
  }
}

async function deactivateQuiz(id) {
  console.log(id);

  let supabase = useSupabaseClient();
  try {
    const { data: deactivatedQuiz } = await supabase
        .from("quiz")
        .update({
          status: "deactivated",
        })
        .eq("id", id);
  } catch (error) {
    console.log(error);
  }
}
let userInformation = ref([]);
async function getUser() {
  let userGet = useSupabaseUser();

  user.value = userGet.value?.id;

  try {
    let supabase = useSupabaseClient();
    const { data: userData, error: errorUser } = await supabase
        .from("profiles")
        .select("*")
        .eq("user_id", user.value)
        .single();
    if (errorUser) {
      return;
    }
    userInformation.value = userData;
    console.log("Profile", profile.value);

    console.log(user.value?.id);
  } catch (error) {
    console.log(error);
  }
}

let quizInformation = ref([]);
async function getQuiz() {
  let supabase = useSupabaseClient();
  let user = useSupabaseUser();
  let currentUser = user.value?.id;
  try {
    const { data: quizData } = await supabase
        .from("quiz")
        .select("*")
        .eq("users_id", currentUser);

    quizInformation.value = quizData;
  } catch (error) {
    console.log(error);
  }
}

onMounted(() => {
  if (role == "content Creater") {
    getQuiz();
  }

  getStats();
  getChallenges();
  getUser();

});
</script>

<template>



  <div class="bg-gray-900 h-screen w-full p-6 text-white">
    <h1 class="text-4xl mb-6">Profile</h1>



    <div v-if="role == 'player'">

      {{challengePlayers}}

      <h1 class="text-3xl text-center mb-4">Player: {{ name }}</h1>

      <div class="bg-white text-gray-900 p-6 rounded-lg shadow-lg mb-6">
        <div class="grid grid-cols-3 gap-4 mb-4">
          <div class="bg-gray-800 text-white p-4 rounded-lg">
            Points: {{ stats.points }}
          </div>
          <div class="bg-gray-800 text-white p-4 rounded-lg">Ranking: 450</div>
          <div class="bg-gray-800 text-white p-4 rounded-lg">
            Games Played: {{ stats.games_played }}
          </div>
        </div>
      </div>



      <h2 class="text-2xl text-center mb-4">Challenge History</h2>
      <table class="w-full bg-white text-gray-900 rounded-lg shadow-lg mb-6">
        <thead>
        <tr class="bg-gray-800 text-white">
          <th class="p-4">Quiz Name</th>
          <th class="p-4">user_profile_name?</th>
          <th class="p-4">Challenger_name</th>
          <th class="p-4">User Score</th>
          <th class="p-4">Opponents Score</th>
          <th class="p-4">Winner</th>
          <th class="p-4">Status</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="item in challengePlayers" :key="item.id" class="border-b">
          <td class="p-4">{{ item.quiz_name }}</td>
          <td class="p-4">{{ item.user_profile_name }}</td>
          <td class="p-4">{{ item.challenger_name }}</td>
          <td class="p-4">{{ item.challenger_score }}</td>
          <td class="p-4">{{ item.reciever_score }}</td>
          <td class="p-4">{{ item.status }}</td>
        </tr>
        </tbody>
      </table>
    </div>

    <div v-if="role == 'content Creater'">
      <h1 class="text-3xl text-center mb-4">Hello {{ name }}</h1>

      <div class="bg-white text-gray-900 p-6 rounded-lg shadow-lg mb-6">
        <div class="grid grid-cols-3 gap-4 mb-4">
          <div class="bg-gray-800 text-white p-4 rounded-lg">Quiz Created</div>
          <div class="bg-gray-800 text-white p-4 rounded-lg">
            Attempted By People
          </div>
          <div class="bg-gray-800 text-white p-4 rounded-lg"></div>
        </div>
      </div>

      <table class="w-full bg-white text-gray-900 rounded-lg shadow-lg mb-6">
        <thead>
        <tr class="bg-gray-800 text-white">
          <th class="p-4">Quiz</th>
          <th class="p-4">Status</th>
          <th class="p-4"></th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="item in quizInformation" :key="item.id" class="border-b">
          <td class="p-4">{{ item.name }}</td>
          <td class="p-4">{{ item.status }}</td>
          <td class="p-4">
            <button
                @click="deactivateQuiz(item.id)"
                class="bg-red-500 text-white p-2 rounded-lg hover:bg-red-600 transition duration-300"
            >
              Deactivate
            </button>
          </td>
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

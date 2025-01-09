<script setup lang="ts">


import {SupabaseClient} from "@supabase/supabase-js";
import {getData} from "@redocly/ajv/lib/compile/validate";
import{useRoleStore} from "#imports";
const useRole=useRoleStore();
import {useSupabaseUser} from "#imports";
import {ca} from "cronstrue/dist/i18n/locales/ca";
import {de} from "cronstrue/dist/i18n/locales/de";


let role=useRole.role;
let name=useRole.name;
let user=ref()
let profile=useRole.id
let quizNames=ref([])

let challenges=ref([]);

let challengePlayers=ref([])

let names=ref([])
async function getChallenges() {
  let supabase = useSupabaseClient()

  try {
    const {data: challengeValues, error: challengeErrors} = await supabase
        .from('challenge')
        .select('*')
        .or(`challenger_id.eq.${profile},reciever_id.eq.${profile}`);


    if (challengeErrors) {
      console.log(challengeErrors);
    }

    challenges.value = challengeValues;

    const userIds = [
      ...new Set([
        ...challengeValues?.map(challenge => challenge.challenger_id),
        ...challengeValues?.map(challenge => challenge.reciever_id),

      ])

    ];


    const quizIds=[...new Set(challengeValues?.map(challenge=>challenge.quiz_id))];


    const {
      data: userProfiles, error: profileError} = await supabase.from('profiles').select('id,name').in('id', userIds);

    console.log("Profiles", userProfiles)


    const {data: quizInfo, error: quizError} = await supabase.from('quiz').select('id,name').in('id', quizIds);
    if (quizError) {
      console.log(quizError)

    }

    challengePlayers.value = challengeValues.map(challenge => ({
      ...challenge,
      user_profile_name: userProfiles.find(user => user.id === challenge.reciever_id)?.name,
      challenger_name: userProfiles.find(user => user.id === challenge.challenger_id)?.name,
      quiz_name:quizInfo.find(quiz=>quiz.id===challenge.quiz_id)?.name
    }))




}



  catch (error)
  {
    console.log(error);
  }

}

let stats=ref([])
async function getStats()
{
  let currentProfile=useRoleStore().id;
console.log('curr',currentProfile)
  let supabase=useSupabaseClient()
  try {

    const {data:statsValues,error:errorValues} =await  supabase.from('stats').select('*').eq('user_profile_id', currentProfile).single()


    if(errorValues){
      console.log(errorValues);
    }
    stats.value = statsValues;
    console.log("Stats",statsValues)
  }

  catch(error)
  {
    console.log(error)
  }

}


async function deactivateQuiz(id)
{
  console.log(id)

  let supabase=useSupabaseClient()
  try{
    const{data:deactivatedQuiz}=await supabase.from('quiz').update({
      status:'deactivated'
    }).eq('id',id)



  }
  catch(error){
    console.log(error)
  }



}
let userInformation=ref([])
async function getUser()
{
  let userGet=useSupabaseUser();

  user.value=userGet.value?.id
  console.log("User",user.value)
  try{
    let supabase=useSupabaseClient();
    const{data:userData,error:errorUser}=await supabase.from('profiles').select('*').eq(
        'user_id',user.value
    ).single()
    if(errorUser)
    {
      return;
    }
    userInformation.value=userData;
    console.log("Profile",profile.value)





    console.log(user.value?.id);

  }
  catch (error){
    console.log(error);
  }
}

let quizInformation=ref([])
async function getQuiz()
{
  let supabase=useSupabaseClient()
  let user=useSupabaseUser()
  let currentUser=user.value?.id
  try{
    const{data:quizData}=await supabase.from('quiz').select('*').eq('users_id',currentUser)

  quizInformation.value=quizData;
    }
  catch(error)
  {
    console.log(error)
  }


}








onMounted(()=>{
  if(role=='content Creater')
  {
    getQuiz()
  }


  getUser();
  getChallenges()
  getStats()
})


</script>

<template>

  {{challengePlayers}}

<h1>
  Profile


</h1>
  <div class="bg-blue-900 h-screen w-full">

{{quizInformation}}



    <div v-if="role=='player'">

    <h1 class="text-white text-3xl text-center">
   Player:   {{name}}

    </h1>


    <div class="flex flex-col bg-white">
    <div class="grid grid-cols-3 border-b-2 gap-3 mb-4">
      <div class=" bg-black border p-4 text-white">Points</div>
      <div class=" bg-black border p-4 text-white"> Ranking</div>
      <div class="  bg-black border p-4 text-white"> Games Played
      </div>
    </div>
      <div class="grid grid-cols-3 border-b-2 gap-3">
        <div class=" bg-black border p-4 text-white">{{stats.points}}</div>
        <div class=" bg-black border p-4 text-white"> 450</div>
        <div class="  bg-black border p-4 text-white"> {{stats.games_played}}
        </div>

      </div>

      <h2 class="text-center">
        Recent Quiz Attempted
      </h2>

    </div>

    <h1 class="text-white text-3xl text-center">
      Player:   {{profile.name}}

    </h1>


    <div class="flex flex-col bg-white">



    </div>





    <div class="items-center justify-center">
     <h2 class="text-white text-center">
       Challenge History
     </h2>

    <table class="w-full">

      <tr>
        <th class="border-b-2">
Quiz Name
        </th>
        <th class="border-b-2">
           Challenged/Challenge?
        </th>
        <th class="border-b-2">
           Score
        </th>
        <th class="border-b-2">
          Opponents Score
        </th>
        <th class="border-b-2">
          Winner
        </th>
        <th class="border-b-2">
          Status
        </th>


      </tr>
      <tr v-for="item in challengePlayers">
        <td> {{item.quiz_name}}</td>
        <td> {{item.quiz_name}}</td>
        <td> {{item.quiz_name}}</td>
        <td> {{item.quiz_name}}</td>
        <td> {{item.status}}</td>



      </tr>
    </table>
   </div>



  </div>

    <div v-if="role=='content Creater'">


      <h1 class="text-center text-white">
        Hello{{name}}
      </h1>

      <div class="flex flex-col bg-white">
        <div class="grid grid-cols-3 border-b-2 gap-3 mb-4">
          <div class=" bg-black border p-4 text-white">Quiz Created</div>
          <div class=" bg-black border p-4 text-white"> Attempted By People</div>
          <div class="  bg-black border p-4 text-white">
          </div>
        </div>

      </div>

      <table class="w-full">
        <tr>
        <th class="border-b-2 text-white"> Quiz</th>
        <th class="border-b-2 text-white"> Status</th>
        <th> </th>
        </tr>

        <tr class="border-b-2" v-for="item in quizInformation">
          <td class="text text-white">{{item.name}}</td>
          <td class="text- text-white"> {{item.status}}</td>
          <td class="text-white">
            <button @click="deactivateQuiz(item.id)">deactivate
            </button>
          </td>

        </tr>

      </table>



    </div>



    </div>


</template>

<style scoped>

</style>
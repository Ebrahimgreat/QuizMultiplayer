<script setup lang="ts">


import{useRoleStore} from "~/stores/role";
import {useSupabaseUser} from "#imports";
const roleStore=useRoleStore();
let role=roleStore.role;


async function challengePlayer(item)
{

  alert(`Invitation to ${item.name} Has been sent`);

}
async function getUser()
{
  let supabase=useSupabaseClient();
  console.log(supabase.auth.getUser())

}
let quizInformation=ref([])
async function getAllQuiz()
{
  let supabase=useSupabaseClient();
  const currentUser=useSupabaseUser();
  try{
    const{data:quizData,error:quizError}=await supabase.from('quiz').select('*').eq('users_id',currentUser.value);
    if(quizError){
      console.log('Unable to fetch');
      return;

    }
    quizInformation.value=quizData


  }
  catch (error)
  {
    console.log(error)
  }



}



async function logout()
{
  try{
    const supabase=useSupabaseClient();
    await supabase.auth.signOut();
    navigateTo('/home');
  }
  catch (error)
  {
    console.log(error)
  }

}
function createNewQuiz()
{
  navigateTo('/creatingQuiz')
}

let teachers=ref();

let profiles=ref([])
async function getProfileofUsers()
{
  const supabase=useSupabaseClient();
  const{data:profileData,error:profileError}=await supabase.from('profiles').select('*').eq('role',role);
  if(profileError)
  {
    console.log("Error");
  }
  profiles.value=profileData;


}

async function getCurrentUser() {
  const supabase = useSupabaseClient();

  const { data, error } = await supabase.auth.getUser();

  if (error) {
    console.error('Error fetching current user:', error);
  } else {
    console.log('Current user ID:', data.user?.id);
    console.log('Current user email:', data.user?.email);
  }
}

onMounted(()=>{
  if(role=='player'){
  getProfileofUsers()
    }
   else{
    getAllQuiz()
  }

})

</script>

<template>



  <div v-if="role=='content Creater'">
  <h1 class="text-center"> Hello Teacher
  </h1>


  <button @click="createNewQuiz" class="shadow bg-purple-500 hover:bg-purple-400 focus:shadow-outline-none text-white font-bold py-2 px-4 rounded" type="button">
  Create New Quiz
  </button>
  <table class="table-auto h-full w-full text-left text-white">
      <tr>
      <th class="px-4 py-2 border-blue-100 text-black">
       Name </th>
        <th class="px-4 py-2 boredr gray-100 text-black">
          Category
        </th>
        <th class="px-4 py-2 boredr gray-100 text-black">
Status
        </th>

        <th class="px-4 py-2 border gray-100 text-black">
      View
     </th>
     <th class="px-4 py-2 boredr gray-100 text-black">
       Delete
     </th>
        <th class="px-4 py-2 boredr gray-100 text-black">
          Deactivate
        </th>
    </tr>
   <tr v-for="item in quizInformation" class="px-4 py-2 border gray-100 text-black">
     <td>
       {{item.name}}

     </td>
     <td>

     </td>
     <td>
       {{item.status}}
     </td>

   </tr>

 </table>



  </div>

  <div v-if="role=='player'">
    <h2 class="text-black text-center">
      List of Players that have registered
    </h2>



    <table class="auto h-full w-full bg-blue-900">
      <tr>
        <th class="px-4 py-2">
          Name

        </th>
        <th class="px-4 py-2">

      Ranking
        </th>

        <th class="px-4 py-2">

         Total Points
        </th>
        <th class="px-4 py-2">

         Games Won
        </th>




      </tr>
      <tr v-for="item in profiles" class="border">
        <td class="px-4 py-2 text-white
">{{item.name}}</td>
        <td> <button @click="challengePlayer(item)">Send Request
        </button>
        </td>
      </tr>


    </table>

  </div>

  <div class="flex-col items-center justify-center">
  </div>

</template>

<style scoped>

</style>
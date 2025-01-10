<script setup lang="ts">
import '#components'

import{useRoleStore} from "~/stores/role";
import {ca} from "cronstrue/dist/i18n/locales/ca";
import {useSupabaseUser} from "#imports";
import{usequizStore} from "#imports";
const quizStore=usequizStore();


let roleStore=useRoleStore();
let role=roleStore.role;
let profileId=roleStore.id


let categories=ref(['math','sports','Science','Journalling','Travelling']);

let showItem=ref();

 function takeQuiz(id)
{
  navigateTo({
    path:'/quizTaking',
    query:{
      id:id,
      challenge:''

    }


  })

}




async function quizMainScreen(id:int) {

  challengeId.value = id;
  let response = false
  if (challengeId.value != '') {
    response = confirm('Are you sure You want to challenge this player?')

    if (response) {
      try {
        let supabase = useSupabaseClient();

        const {data: challenge, error: challengeError} = await supabase.from('challenge').insert({
          'quiz_id': quizChosen.value.id,
          'reciever_id': challengeId.value,
          'challenger_id': profileId
        }).select('id').single();
        quizStore.setChallenge(challenge.id);
        if (challengeError) {
          console.log(challengeError)
          return;
        }

      } catch (error) {

      }
      navigateTo({
        path: '/quizScreen',
        query: {
          id: quizChosen.value.id,
          challengeId: id,
          startChallenge: true,
        }
      })
    }

  }
  else{
    navigateTo({
      path:'/quizScreen',
      query:{
        id:quizChosen.value.id,
        startChallenge:false
      }
    })
  }
}
let quizez=ref([])
let filteredArray=ref([])
let category=ref()
let options=ref([])
async function quizData(){
  let supabase=useSupabaseClient();

  try {
    const {data: quizInformation, error: errorInformation} = await supabase.from('quiz').select('*');
    quizez.value = quizInformation
    options.value=quizez.value.map((item)=>item.id);
    console.log(options.value)


    if (errorInformation) {
      console.log("Error");
      return;
    }
  }



  catch(error){
    console.log(error);
  }
}
async function categorySelected(value)
{
  selected.value=value
  value=value+1;
 filteredArray.value=quizez.value.filter(
     (quiz)=>quiz.quiz_category===value
 )


}
let quizChosen=ref(false)
let showOptions=ref(false);

 let challengeId=ref('')
 function toggleOption(item)
{
  quizChosen.value=item
  quizSelected.value=false
  console.log(quizChosen.value.id)

  showOptions.value=!showOptions.value;
}


let quizSelected=ref(true)
function online()
{
  navigateTo({
    path:'/lobby',
    query:{
      id:quizChosen.value.id
    }
  })

}

let selected=ref()

let challengeOption=ref(false)

let players=ref([])
async function  toggleChallenge()
{
  let supabase=useSupabaseClient();
  let user=useSupabaseUser()
  let profile=user.value?.id;
  console.log(profile)
  try{
    const{data}=await supabase.from('profiles').select('*').eq('role','player')
        .neq('user_id',profile);
  players.value=data;
  }

  catch (error)
  {
    console.log(error);
  }


  challengeOption.value=!challengeOption.value;

}

onMounted(()=>{
  if(role=='player'){
    quizData();
  }

})
</script>


<template>




  <div class="bg-gray-900 h-screen w-full p-6 text-white">
    <div v-if="role == 'player'">
      <div class="h-full flex flex-col bg-gray-900">
        <h1 class="text-center text-3xl mb-4">Choose a Category</h1>

        <div class="grid grid-cols-2 gap-4 mb-6">
          <button
              v-for="(item, index) in categories"
              :key="index"
              :value="index"
              class="border p-4 text-center rounded-lg transition duration-300"
              :class="
              selected == index ? 'bg-blue-500' : 'bg-white text-gray-900'
            "
              @click="categorySelected(index, item)"
          >
            {{ item }}
          </button>
        </div>

        <div
            v-if="filteredArray.length === 0"
            class="text-center text-white mb-4"
        >
          There are no results
        </div>

        <div v-else>
          <h2 class="text-center text-2xl mb-4">
            Showing Quiz of Category Selected
          </h2>
          <div class="grid grid-cols-1 gap-4 mb-6">
            <button
                v-for="(item, index) in filteredArray"
                :key="index"
                @click="toggleOption(item)"
                class="block text-white text-sm font-bold mb-2 shadow appearance-none border border-red-500 rounded w-full py-2 px-3 leading-tight focus:outline-none transition duration-300 hover:bg-red-600"
            >
              {{ item.name }}
            </button>
          </div>

          <div v-if="quizChosen" class="text-center text-white mb-4">
            Quiz Selected: {{ quizChosen.name }}
          </div>

          <div v-if="showOptions" class="grid grid-cols-2 gap-4 mb-6">
            <button
                @click="quizMainScreen('')"
                class="block text-white text-sm font-bold shadow appearance-none border p-4 rounded w-full transition duration-300 hover:bg-gray-700"
            >
              Solo
            </button>

            <button
                @click="toggleChallenge"
                class="block text-white text-sm font-bold shadow appearance-none border border-red-500 rounded w-full transition duration-300 hover:bg-red-600"
            >
              Challenge
            </button>

            <button
                @click="online"
                class="block text-white text-sm font-bold shadow appearance-none border border-red-500 rounded w-full transition duration-300 hover:bg-red-600"
            >
              play online
            </button>
          </div>

          <div v-if="challengeOption" class="flex flex-col items-center mb-6">
            <h3 class="text-white mb-2">Choose a Player</h3>
            <div
                class="overflow-y-auto max-h-64 border border-gray-300 rounded-md w-full"
            >
              <table class="w-full bg-white text-gray-900 rounded-lg shadow-lg">
                <thead>
                <tr class="bg-gray-800 text-white">
                  <th class="p-4">Name</th>
                  <th class="p-4">Challenge</th>
                </tr>
                </thead>
                <tbody>
                <tr v-for="item in players" :key="item.id" class="border-b">
                  <td class="p-4 text-white">{{ item.name }}</td>
                  <td class="p-4">
                    <button
                        @click="quizMainScreen(item.id)"
                        class="bg-green-500 text-white p-2 rounded hover:bg-green-600 transition duration-300"
                    >
                      Challenge
                    </button>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="role == 'content Creater'">
      <creating-quiz></creating-quiz>
    </div>
  </div>
</template>



<style scoped>

</style>
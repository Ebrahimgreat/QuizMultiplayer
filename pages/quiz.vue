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
function online(id)
{
  navigateTo({
    path:'/lobby',
    query:{
      id:id
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




  <div v-if="role=='player'">


    <div class="h-screen flex flex-col bg-blue-900">

      <h1 class="text-center text-white">
        Choose a Category
      </h1>

      <div class="grid grid-cols-2 gap-4 border-b-2">
        <button  :value="index" v-for="(item,index) in categories" class="border p-4 text-center bg-gray-400" v-bind:style="{backgroundColor:selected==index?'blue':'white'}" @click="categorySelected(index,item)">
          {{item}}
        </button>
      </div>
      <div>
      <div v-for="item in filteredArray">

        <div v-if="item.name=='' || item.name==null">
          There are no results
        </div>
      </div>
        <h2 class="text-center">
          <button>
            Next
          </button>
        </h2>




        <h2 class="text-center text-white"> Showing Quiz of Category Selected
</h2>
        <div class="grid flex-col items-center justify-center">
          <div v-for="(item,index) in filteredArray">


            <div v-if="quizSelected">
            <button @click="toggleOption(item)" class="block text-white text-sm font-bold mb-2  shadow appearance-none border border-red-500 rounded w-full py-2 px-3  leading-tight focus:outline-none">{{item.name}}</button>
            </div>
          </div>

            <div v-if="quizChosen">
            Quiz Selected:{{quizChosen.name}}
            </div>

      <div v-if="showOptions" class="grid grid-cols-3 gap-4 border-b-2">

     <button @click="quizMainScreen('')" class="block text-white text-sm font-bold mr-12 shadow appearance-none border p-4 rounded w-full">
       Solo
     </button>

        <button @click="toggleChallenge" class="block text-white text-sm font-bold mb-2 shadow appearance-none border border-red-500 rounded w-full">Challenge</button>





        <div v-if="challengeOption" class="flex flex-col">


          <h3 class="text-white mb-2" > Choose a Player </h3>
          <div class="overflow-y-auto max-h-64 border border-gray-300 rounded-md">
          <table>
            <tr>

       <th> Name</th>
              <th> Challenge</th>
            </tr>

            <tr v-for="item in players">
              <td class="text-white">
               {{item.name}}
              </td>
            <td class="text-white">
              <button @click="quizMainScreen(item.id)">



              Challenge
              </button>
            </td>
            </tr>







          </table>
          </div>
        </div>



      </div>
    </div>
        </div>

    </div>
    </div>


  <div v-if="role=='content Creater'">

    <creating-quiz>

    </creating-quiz>
  </div>

</template>

<style scoped>

</style>